# SPI UVM Verification

**SystemVerilog와 UVM 1.2를 이용한 SPI Master–Slave 양방향 데이터 검증 프로젝트**입니다. Directed·Constrained Random 자극을 생성하고, Scoreboard에서 송수신 데이터를 비교하며 Functional Coverage를 수집하도록 구성했습니다.

## 프로젝트 개요

| 항목 | 내용 |
|---|---|
| 검증 대상 | 8비트 SPI Master–Slave 통합 DUT |
| 검증 범위 | SPI Mode 0 — CPOL=0, CPHA=0 |
| 언어 / 방법론 | SystemVerilog / UVM 1.2 |
| 실행 도구 | Synopsys VCS, Verdi FSDB, URG |
| 기본 시나리오 | Directed 8건 + Random 992건 = 총 1,000건 |
| 기본 Seed | 1234 |
| 비교 기준 | Master RX = Slave TX, Slave RX = Master TX |

위 건수는 현재 시퀀스에 설정된 실행 계획입니다. 제공된 파일에는 PASS/FAIL 요약 로그와 Coverage 보고서가 없어 **통과 건수나 Coverage 달성률은 기재하지 않았습니다.**

## 검증 환경

```text
spi_test
└── spi_env
    ├── spi_agent
    │   ├── spi_sequencer → spi_driver → spi_if → DUT
    │   └── spi_monitor ← spi_if ← DUT
    │           ├── analysis port → spi_scoreboard
    │           └── analysis port → spi_coverage
    ├── spi_scoreboard : 양방향 데이터 비교 및 PASS/FAIL 집계
    └── spi_coverage   : 데이터·분주 조건 및 조합 커버리지 수집
```

Driver는 DUT의 병렬 송신 입력과 시작 신호를 구동합니다. Monitor는 시작 시 송신 조건을 저장하고 `master_done` 이후 수신 데이터를 읽어 Scoreboard와 Coverage에 전달합니다. SPI 선로를 독립적으로 디코딩하는 방식이 아니라 **통합 DUT의 입력과 출력 바이트를 비교하는 환경**입니다.

## 주요 구현

- **Sequence Item:** Master·Slave 송신 데이터와 분주값을 랜덤 변수로 정의하고 Mode 0 제약을 적용했습니다.
- **Sequence:** 주요 데이터 조합을 Directed 시나리오로 발생시키고 나머지 전송은 랜덤 데이터로 구성했습니다.
- **Driver / Monitor:** Virtual Interface를 통해 자극을 전달하고 전송 결과를 Transaction으로 수집합니다.
- **Scoreboard:** 양방향 수신 데이터가 상대 측 송신 데이터와 같은지 비교하고 PASS·FAIL을 집계합니다.
- **Coverage Subscriber:** 데이터 구간, 클록 분주 구간, 양방향 zero/nonzero 조합을 수집합니다.

## 시나리오

| 번호 | Master TX | Slave TX | CLK_DIV | 목적 |
|---:|---:|---:|---:|---|
| 1 | 00 | 00 | 4 | 양방향 zero |
| 2 | 00 | A5 | 8 | zero / nonzero |
| 3 | 5A | 00 | 12 | nonzero / zero |
| 4 | A5 | 3C | 16 | 양방향 nonzero |
| 5 | FF | FF | 20 | 최댓값 |
| 6 | 01 | FE | 5 | 낮은 값 / 높은 값 |
| 7 | 80 | 7F | 10 | 중간 구간 |
| 8 | C0 | 01 | 3 | 높은 값 / 낮은 값 |

이후 992건은 송신 바이트를 랜덤화하고 `clk_div`를 **3~20**으로 제한합니다. Sequence Item 자체의 분주 제약은 2~20이지만, 현재 랜덤 시퀀스는 추가 제약으로 3~20을 사용합니다.

## Functional Coverage

| 항목 | Bin 구성 |
|---|---|
| SPI Mode | Mode 0, 다른 Mode는 ignore |
| Master / Slave TX | 00, FF, 01~3F, 40~BF, C0~FE |
| CLK_DIV | Fast 2~5, Mid 6~12, Slow 13~20 |
| Master / Slave 데이터 상태 | zero / nonzero |
| Cross | Mode × CLK_DIV, Master zero/nonzero × Slave zero/nonzero |

Coverage는 설정한 Bin의 방문 여부를 나타냅니다. 예를 들어 Fast Bin이 채워져도 분주값 2~5를 각각 모두 실행했다는 의미는 아닙니다. 데이터 비교 결과와 Coverage는 함께 확인합니다.

## 파일 구조

```text
spi-uvm-verification/
├── README.md
├── .gitignore
├── docs/
│   └── review_notes.md
├── uvm/
│   ├── Makefile
│   ├── spi.sv                 # UVM에서 사용하는 통합 DUT
│   └── tb/
│       ├── tb_top.sv
│       ├── spi_if.sv
│       ├── spi_pkg.sv
│       ├── spi_seq_item.sv
│       ├── spi_sequence.sv
│       ├── spi_sequencer.sv
│       ├── spi_driver.sv
│       ├── spi_monitor.sv
│       ├── spi_scoreboard.sv
│       ├── spi_coverage.sv
│       ├── spi_agent.sv
│       ├── spi_env.sv
│       └── spi_test.sv
└── board/
    ├── rtl/master/            # Basys3 Master 구현
    ├── rtl/slave/             # Basys3 Slave 구현
    └── constraints/           # 보드별 XDC
```

`uvm/spi.sv`와 `board/rtl/`은 서로 다른 RTL 버전입니다. UVM 실행은 `uvm/spi.sv`만 사용하며 보드용 RTL을 함께 컴파일하지 않습니다. 통합 DUT 안에도 `spi_master`, `spi_slave`가 있어 함께 넣으면 모듈 정의가 중복됩니다.

## 실행 방법

Linux에서 VCS 및 UVM 1.2를 사용할 수 있는 환경이 필요합니다. `tb_top.sv`는 FSDB 시스템 태스크를 호출하므로 VCS와 Verdi의 FSDB 연동 설정도 필요합니다. MobaXterm은 이 서버에 접속하는 도구입니다.

```bash
cd uvm
make comp
make sim TEST=spi_test SEED=1234 INFO_LEVEL=UVM_LOW
make urg
```

`make sim`은 원본 Makefile 정의에 따라 컴파일도 수행합니다. URG 출력 위치는 `uvm/urgReport/`입니다. 콘솔 결과를 보관하려면 Bash에서 다음과 같이 실행할 수 있습니다.

```bash
set -o pipefail
make sim TEST=spi_test SEED=1234 2>&1 | tee run_spi_test_1234.log
```

확인할 항목은 `SEQUENCE SUMMARY`, `SPI RESULT`, UVM_ERROR·UVM_FATAL 집계, `SPI_COV` 출력입니다. 문서 정리 과정에서 VCS 시뮬레이션을 새로 실행하지는 않았습니다.

## 보드용 설계

Basys3 (`xc7a35tcpg236-1`)에서 Master는 스위치 데이터와 시작 버튼을 입력받고, Slave는 수신 바이트를 FND에 표시합니다. Master Top은 Mode 0과 분주값 255, Slave Top은 응답 바이트 0x3C로 설정되어 있습니다.

Master·Slave 각각의 RTL 폴더와 대응 XDC를 별도 Vivado 프로젝트에 추가하고 Top을 `top_spi`, `top_spi_slave`로 지정합니다. 보드 버전의 동작 결과를 UVM DUT의 결과와 동일하게 취급하지 않습니다.

## 검토 상태

업로드용 정리에서는 원본 RTL·UVM 소스·Makefile을 유지하고, 중복 테스트벤치·템플릿·Vivado 캐시·Verdi 실행 산출물을 제외했습니다. 재실행 전 확인할 코드와 환경 사항은 [검토 메모](docs/review_notes.md)에 정리했습니다.
