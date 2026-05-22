# axi_stream_dw_downsizer_wrapper.sv

`axi_stream_dw_downsizer`의 AMD 커스텀 IP 패키징용 flat-port 래퍼. Vivado IP 패키징 요구사항에 맞게 struct/interface 포트를 모두 `logic` 신호로 대체하고, `parameter type`을 정수 파라미터로 교체한다.

---

## Module: `axi_stream_dw_downsizer_wrapper`

### Parameters

| Parameter      | Type         | Default | Description                                   |
|----------------|--------------|---------|-----------------------------------------------|
| `DataWidthIn`  | int unsigned | 32      | 입력 데이터 폭 (bits); `DataWidthOut`의 정수배  |
| `DataWidthOut` | int unsigned | 8       | 출력 데이터 폭 (bits); `DataWidthIn`보다 작아야 함 |
| `IdWidth`      | int unsigned | 1       | ID 폭 (bits)                                   |
| `DestWidth`    | int unsigned | 1       | Destination 폭 (bits)                          |
| `UserWidth`    | int unsigned | 1       | User 사이드밴드 폭 (bits)                       |

### Ports

| Port             | Dir    | Width           | Description                    |
|------------------|--------|-----------------|--------------------------------|
| `clk_i`          | input  | 1               | 클록                           |
| `rst_ni`         | input  | 1               | 비동기 리셋 (active-low)        |
| `s_axis_tdata`   | input  | **DataWidthIn** | 입력 데이터 (넓은 버스)          |
| `s_axis_tstrb`   | input  | DataWidthIn/8   | 입력 바이트 스트로브              |
| `s_axis_tkeep`   | input  | DataWidthIn/8   | 입력 바이트 킵                   |
| `s_axis_tlast`   | input  | 1               | 입력 패킷 마지막 beat             |
| `s_axis_tid`     | input  | IdWidth         | 입력 스트림 ID                   |
| `s_axis_tdest`   | input  | DestWidth       | 입력 라우팅 목적지                |
| `s_axis_tuser`   | input  | UserWidth       | 입력 사용자 사이드밴드             |
| `s_axis_tvalid`  | input  | 1               | 입력 유효                        |
| `s_axis_tready`  | output | 1               | 입력 준비                        |
| `m_axis_tdata`   | output | **DataWidthOut**| 출력 데이터 (좁은 버스)           |
| `m_axis_tstrb`   | output | DataWidthOut/8  | 출력 바이트 스트로브              |
| `m_axis_tkeep`   | output | DataWidthOut/8  | 출력 바이트 킵                   |
| `m_axis_tlast`   | output | 1               | 출력 패킷 마지막 beat             |
| `m_axis_tid`     | output | IdWidth         | 출력 스트림 ID                   |
| `m_axis_tdest`   | output | DestWidth       | 출력 라우팅 목적지                |
| `m_axis_tuser`   | output | UserWidth       | 출력 사용자 사이드밴드             |
| `m_axis_tvalid`  | output | 1               | 출력 유효                        |
| `m_axis_tready`  | input  | 1               | 출력 준비                        |

### Block Diagram

```mermaid
flowchart LR
  subgraph Slave["Slave (s_axis_*)\nDataWidthIn bits"]
    SD[tdata\ntstrb / tkeep\ntlast / tid\ntdest / tuser\ntvalid / tready]
  end

  subgraph axi_stream_dw_downsizer_wrapper
    direction LR
    RS["flat → in_req\nin_rsp → s_axis_tready"]
    DS["axi_stream_dw_downsizer\n────────────────────\nFSM: AcceptDataIn\n     DataOut\n     LastDataOut\nshift register\ncounter"]
    TM["out_req → flat\nm_axis_tready → out_rsp"]
  end

  subgraph Master["Master (m_axis_*)\nDataWidthOut bits"]
    MD[tdata\ntstrb / tkeep\ntlast / tid\ntdest / tuser\ntvalid / tready]
  end

  Slave -->|DataWidthIn| RS --> DS --> TM -->|DataWidthOut| Master
```

### 내부 구조

1. `AXI_STREAM_TYPEDEF_ALL`으로 in/out 각각의 req/rsp struct 타입 정의 (데이터 폭 상이)
2. flat `s_axis_*` 입력 신호 → `in_req` struct 필드 assign
3. `axi_stream_dw_downsizer` 코어 인스턴스
4. `out_req` struct 필드 → flat `m_axis_*` 출력 신호 assign

### 사용 예시

```
DataWidthIn=32, DataWidthOut=8 인 경우:
  입력 1 beat (32-bit) → 출력 4 beats (8-bit × 4)
  처리량: 출력 측 처리량 = 입력 측 처리량 / 4
```
