# 고성능 온칩 통신을 위한 AXI Stream SystemVerilog 모듈
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/pulp-platform/axi_stream?color=blue&label=current&sort=semver)](CHANGELOG.md)
[![SHL-0.51 license](https://img.shields.io/badge/license-SHL--0.51-green)](LICENSE)

이 저장소는 [AXI4 Stream 명세][AMBA 5 Stream Spec]를 준수하는 온칩 통신 네트워크를 구축하기 위한 모듈을 제공합니다.

저희의 **설계 목표**는 다음과 같습니다:
- **토폴로지 독립성**: 사용자가 임의의 네트워크 토폴로지를 구현할 수 있는 기본 빌딩 블록을 제공합니다.
- **모듈성**: 가능한 한 구성(configuration) 기반 설계보다 조합(composition) 기반 설계를 선호합니다. 하드웨어에 *Unix 철학*을 적용하여 각 모듈이 하나의 역할을 잘 수행하도록 노력합니다. 이는 보다 특화된 네트워크를 구축할 때 파라미터 값을 변경하는 것보다 모듈을 직렬로 인스턴스화하는 경우가 더 많음을 의미합니다.
- **이기종 네트워크 적합성**: 모듈은 데이터 폭과 트랜잭션 동시성 측면에서 파라미터화가 가능합니다. 이를 통해 광범위한 성능(예: 대역폭, 동시성, 타이밍), 전력 및 면적 요구사항에 최적화된 네트워크를 구성할 수 있습니다.
- **완전한 AXI 표준 준수**.
- [다양한 (최신 버전의) EDA 도구](#지원되는-eda-도구는-무엇인가요)와의 **호환성** 및 표준화된 합성 가능한 SystemVerilog로의 구현.

## 모듈 목록

아래 표에 링크된 문서 외에도, [인라인 독스트링에서 자동 생성된 문서](https://pulp-platform.github.io/axi_stream)를 준비 중입니다.

| 이름                                                | 설명                                                                              | 문서                                                                              |
|-----------------------------------------------------|-----------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| [`axi_stream_cut`](src/axi_stream_cut.sv)           | 입력과 출력 사이의 모든 조합 경로를 차단합니다.                                   | [Doc](https://pulp-platform.github.io/axi_stream/module.axi_stream_cut.html)      |
| [`axi_stream_dw_downsizer`](src/axi_stream_dw_downsizer.sv) | 넓은 AXI 마스터와 좁은 AXI 슬레이브 사이의 데이터 폭 변환기입니다.     | [Doc](docs/axi_stream_dw_downsizer.md)    |
| [`axi_stream_dw_upsizer`](src/axi_stream_dw_upsizer.sv) | 좁은 AXI 마스터와 넓은 AXI 슬레이브 사이의 데이터 폭 변환기입니다.         | [Doc](docs/axi_stream_dw_upsizer.md)    |
| [`axi_stream_intf`](src/axi_stream_intf.sv)         | 지원되는 인터페이스를 정의하는 파일입니다.                                        |                                                                                   |
| [`axi_stream_multicut`](src/axi_stream_multicut.sv) | 긴 AXI 버스의 타이밍 압력을 완화하는 데 사용할 수 있는 AXI Stream 레지스터입니다. | [Doc](https://pulp-platform.github.io/axi_stream/module.axi_stream_multicut.html) |
| [`axi_stream_test`](test/axi_stream_test.sv)        | AXI Stream 인터페이스용 테스트벤치 유틸리티 모음입니다.                           | [Doc](https://pulp-platform.github.io/axi_stream/package.axi_stream_test.html)    |

### 시뮬레이션 전용 모듈

합성 및 시뮬레이션 모두에서 사용 가능한 위의 모듈 외에도, 다음 모듈은 시뮬레이션에서만 사용할 수 있습니다. 이 모듈들은 저희 테스트벤치에서 광범위하게 사용되며, 이 저장소 외부의 AXI 모듈 및 시스템용 테스트벤치를 구축하는 데에도 적합합니다.

| 이름                                            | 설명                                                                                                   |
|-------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| [`axi_stream_driver`](test/axi_stream_test.sv)  | 임의의 채널에서 개별 비트를 송수신할 수 있는 AXI Stream용 저수준 드라이버입니다.                        |
| [`axi_stream_rand_rx`](test/axi_stream_test.sv) | 제약 가능한 랜덤 지연 및 데이터로 트랜잭션에 응답하는 AXI Stream 수신기 컴포넌트입니다.               |

### 모듈 의존성
![모듈 의존성](https://pulp-platform.github.io/axi_stream/axi_stream.png "AXI Stream의 모듈 계층 구조.")

## 지원되는 EDA 도구는 무엇인가요?

저희 코드는 표준 SystemVerilog([IEEE 1800-2012][], 정확히는)로 작성되었으므로, 더 중요한 질문은 다음과 같습니다: 귀하의 EDA 도구가 어떤 SystemVerilog 서브셋을 지원하나요?

저희는 다양한 EDA 도구와의 호환성을 목표로 합니다. 이를 위해, 특히 합성 가능한 모듈에서 가능한 한 단순한 언어 구문을 사용하려고 노력합니다. 더 많은 EDA 도구와 호환될 수 있도록 코드를 더욱 단순화하는 기여를 장려합니다. 또한 특정 EDA 도구가 저희 코드에서 겪을 수 있는 문제를 우회하는 기여도 환영합니다. 단, 다음 조건을 충족해야 합니다:
- 해당 EDA 도구가 충분히 널리 사용되어야 하고,
- 최신 버전의 EDA 도구가 영향을 받아야 하며,
- 우회 방법이 다른 도구의 기능을 손상시키지 않아야 하고,
- 우회 방법이 코드를 심각하게 복잡하게 만들거나 유지 관리 부담을 가중시키지 않아야 합니다.

또한, SystemVerilog 언어 지원 관련 문제는 EDA 벤더에게 직접 보고하시기를 권장합니다. 저희 코드는 완전히 공개되어 있으며, 발생한 언어 문제에 대한 테스트 케이스로 EDA 벤더와 공유할 수 있습니다.

각 릴리스 및 기본 브랜치의 모든 코드는 최소 하나의 업계 표준 RTL 시뮬레이터 및 합성 도구의 최신 버전에서 테스트됩니다.


[AMBA 5 Stream Spec]: https://documentation-service.arm.com/static/60d5b244677cf7536a55c23e?token=
[IEEE 1800-2012]: https://standards.ieee.org/standard/1800-2012.html
