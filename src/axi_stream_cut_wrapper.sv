// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

`include "axi_stream/typedef.svh"

/// AMD custom IP wrapper for axi_stream_cut.
/// Replaces interface/struct ports with flat logic signals for Vivado IP packaging.
module axi_stream_cut_wrapper #(
  /// Bypass enable (0 = register cut, 1 = pass-through)
  parameter bit          Bypass    = 1'b0,
  /// AXI Stream Data Width (bits)
  parameter int unsigned DataWidth = 32,
  /// AXI Stream ID Width (bits)
  parameter int unsigned IdWidth   = 1,
  /// AXI Stream Destination Width (bits)
  parameter int unsigned DestWidth = 1,
  /// AXI Stream User Width (bits)
  parameter int unsigned UserWidth = 1
) (
  /// Clock
  input  logic                     clk_i,
  /// Asynchronous reset, active low
  input  logic                     rst_ni,

  // Slave (RX) AXI4-Stream port
  input  logic [DataWidth-1:0]     s_axis_tdata,
  input  logic [DataWidth/8-1:0]   s_axis_tstrb,
  input  logic [DataWidth/8-1:0]   s_axis_tkeep,
  input  logic                     s_axis_tlast,
  input  logic [IdWidth-1:0]       s_axis_tid,
  input  logic [DestWidth-1:0]     s_axis_tdest,
  input  logic [UserWidth-1:0]     s_axis_tuser,
  input  logic                     s_axis_tvalid,
  output logic                     s_axis_tready,

  // Master (TX) AXI4-Stream port
  output logic [DataWidth-1:0]     m_axis_tdata,
  output logic [DataWidth/8-1:0]   m_axis_tstrb,
  output logic [DataWidth/8-1:0]   m_axis_tkeep,
  output logic                     m_axis_tlast,
  output logic [IdWidth-1:0]       m_axis_tid,
  output logic [DestWidth-1:0]     m_axis_tdest,
  output logic [UserWidth-1:0]     m_axis_tuser,
  output logic                     m_axis_tvalid,
  input  logic                     m_axis_tready
);

  typedef logic [DataWidth-1:0]   tdata_t;
  typedef logic [DataWidth/8-1:0] tstrb_t;
  typedef logic [DataWidth/8-1:0] tkeep_t;
  typedef logic [IdWidth-1:0]     tid_t;
  typedef logic [DestWidth-1:0]   tdest_t;
  typedef logic [UserWidth-1:0]   tuser_t;

  `AXI_STREAM_TYPEDEF_ALL(s, tdata_t, tstrb_t, tkeep_t, tid_t, tdest_t, tuser_t)

  s_req_t rx_req, tx_req;
  s_rsp_t rx_rsp, tx_rsp;

  // Flat slave ports → RX request/response structs
  assign rx_req.tvalid = s_axis_tvalid;
  assign rx_req.t.data = s_axis_tdata;
  assign rx_req.t.strb = s_axis_tstrb;
  assign rx_req.t.keep = s_axis_tkeep;
  assign rx_req.t.last = s_axis_tlast;
  assign rx_req.t.id   = s_axis_tid;
  assign rx_req.t.dest = s_axis_tdest;
  assign rx_req.t.user = s_axis_tuser;
  assign s_axis_tready = rx_rsp.tready;

  // TX request/response structs → flat master ports
  assign m_axis_tvalid = tx_req.tvalid;
  assign m_axis_tdata  = tx_req.t.data;
  assign m_axis_tstrb  = tx_req.t.strb;
  assign m_axis_tkeep  = tx_req.t.keep;
  assign m_axis_tlast  = tx_req.t.last;
  assign m_axis_tid    = tx_req.t.id;
  assign m_axis_tdest  = tx_req.t.dest;
  assign m_axis_tuser  = tx_req.t.user;
  assign tx_rsp.tready = m_axis_tready;

  axi_stream_cut #(
    .Bypass           (Bypass),
    .s_chan_t         (s_s_chan_t),
    .axi_stream_req_t (s_req_t),
    .axi_stream_rsp_t (s_rsp_t)
  ) i_axi_stream_cut (
    .clk_i,
    .rst_ni,
    .rx_req_i (rx_req),
    .rx_rsp_o (rx_rsp),
    .tx_req_o (tx_req),
    .tx_rsp_i (tx_rsp)
  );

endmodule : axi_stream_cut_wrapper
