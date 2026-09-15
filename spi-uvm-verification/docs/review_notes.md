# 소스 검토 메모

이 문서는 정적 소스 확인 결과입니다. 시뮬레이션 통과 결과를 대체하지 않습니다.

## 원본 유지

UVM Makefile의 활성 소스 목록은 `spi.sv`, `spi_if.sv`, `spi_pkg.sv`, `tb_top.sv`입니다. Package에서 사용하는 클래스 파일을 함께 복사했습니다. `tb_spi.sv`, `tb_spi_single_pass_backup.sv`, `template.sv`는 활성 목록에 없으므로 제외했습니다. 원본 폴더의 파일은 수정하지 않았습니다.

## 재실행 전 확인 사항

1. `uvm/spi.sv` Master IDLE 분기의 `mosi <= 1'b1 <= 1'b1;`은 비교식을 대입하는 형태로 해석될 수 있는 비정상적인 중복 표현입니다. 의도가 `mosi <= 1'b1;`인지 확인 후 수정·재검증하는 것이 좋습니다. 이번 정리에서는 그대로 유지했습니다.
2. Driver와 Monitor는 `master_done`을 무기한 기다립니다. 완료 신호가 누락되면 테스트가 종료되지 않을 수 있으므로, 후속 개선 시 timeout을 추가할 수 있습니다.
3. Monitor는 SPI 핀을 독립적으로 감시하지 않으며 `slave_done` 발생 여부를 검사하지 않습니다. 현재 범위는 통합 DUT의 양방향 데이터 비교입니다.
4. `tb_top.sv`에 FSDB dump 호출이 있습니다. 서버의 기존 VCS/Verdi 연동이 없는 환경에서는 해당 설정을 준비해야 합니다.
5. 초기 리셋 해제가 클록 상승 에지와 같은 시점에 일어납니다. 반복 실행 시 경합 여부를 점검할 수 있습니다.
6. 보드 Master 버전과 UVM Master 버전은 다릅니다. 특히 CPHA=0 마지막 수신 데이터 저장 방식이 다르므로 UVM 결과를 보드 RTL의 검증 결과로 그대로 사용하지 않습니다.

## 아직 확보되지 않은 증빙

- 해당 소스 버전의 실행 Seed와 PASS/FAIL 요약 로그
- UVM_ERROR·UVM_FATAL 집계
- Functional Coverage 수치와 URG 보고서

소스에는 총 1,000건 및 Coverage 목표가 설정되어 있지만, 이를 실제 달성 결과로 기록하지 않았습니다.
