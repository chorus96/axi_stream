// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

`include "axi_stream/typedef.svh"

/// AMD custom IP wrapper for axi_stream_dw_upsizer.
/// Replaces interface/struct ports with flat logic signals for Vivado IP packaging.
module axi_stream_dw_upsizer_wrapper #(
  /// AXI Stream Data Width In (bits); must be less than DataWidthOut
  parameter int unsigned DataWidthIn  = 8,
  /// AXI Stream Data Width Out (bits); must be a multiple of DataWidthIn
  parameter int unsigned DataWidthOut = 32,
  /// AXI Stream ID Width (bits)
  parameter int unsigned IdWidth      = 1,
  /// AXI Stream Destination Width (bits)
  parameter int unsigned DestWidth    = 1,
  /// AXI Stream User Width (bits)
  parameter int unsigned UserWidth    = 1
) (
  /// Clock
  input  logic                       clk_i,
  /// Asynchronous reset, active low
  input  logic                       rst_ni,

  // Slave (RX) AXI4-Stream port — narrow input
  input  logic [DataWidthIn-1:0]     s_axis_tdata,
  input  logic [DataWidthIn/8-1:0]   s_axis_tstrb,
  input  logic [DataWidthIn/8-1:0]   s_axis_tkeep,
  input  logic                       s_axis_tlast,
  input  logic [IdWidth-1:0]         s_axis_tid,
  input  logic [DestWidth-1:0]       s_axis_tdest,
  input  logic [UserWidth-1:0]       s_axis_tuser,
  input  logic                       s_axis_tvalid,
  output logic                       s_axis_tready,

  // Master (TX) AXI4-Stream port — wide output
  output logic [DataWidthOut-1:0]    m_axis_tdata,
  output logic [DataWidthOut/8-1:0]  m_axis_tstrb,
  output logic [DataWidthOut/8-1:0]  m_axis_tkeep,
  output logic                       m_axis_tlast,
  output logic [IdWidth-1:0]         m_axis_tid,
  output logic [DestWidth-1:0]       m_axis_tdest,
  output logic [UserWidth-1:0]       m_axis_tuser,
  output logic                       m_axis_tvalid,
  input  logic                       m_axis_tready
);

  typedef logic [DataWidthIn-1:0]    tdata_in_t;
  typedef logic [DataWidthIn/8-1:0]  tstrb_in_t;
  typedef logic [DataWidthIn/8-1:0]  tkeep_in_t;
  typedef logic [DataWidthOut-1:0]   tdata_out_t;
  typedef logic [DataWidthOut/8-1:0] tstrb_out_t;
  typedef logic [DataWidthOut/8-1:0] tkeep_out_t;
  typedef logic [IdWidth-1:0]        tid_t;
  typedef logic [DestWidth-1:0]      tdest_t;
  typedef logic [UserWidth-1:0]      tuser_t;

  `AXI_STREAM_TYPEDEF_ALL(s_in,  tdata_in_t,  tstrb_in_t,  tkeep_in_t,  tid_t, tdest_t, tuser_t)
  `AXI_STREAM_TYPEDEF_ALL(s_out, tdata_out_t, tstrb_out_t, tkeep_out_t, tid_t, tdest_t, tuser_t)

  s_in_req_t  in_req;
  s_in_rsp_t  in_rsp;
  s_out_req_t out_req;
  s_out_rsp_t out_rsp;

  // Flat slave ports → IN request/response structs
  assign in_req.tvalid = s_axis_tvalid;
  assign in_req.t.data = s_axis_tdata;
  assign in_req.t.strb = s_axis_tstrb;
  assign in_req.t.keep = s_axis_tkeep;
  assign in_req.t.last = s_axis_tlast;
  assign in_req.t.id   = s_axis_tid;
  assign in_req.t.dest = s_axis_tdest;
  assign in_req.t.user = s_axis_tuser;
  assign s_axis_tready = in_rsp.tready;

  // OUT request/response structs → flat master ports
  assign m_axis_tvalid  = out_req.tvalid;
  assign m_axis_tdata   = out_req.t.data;
  assign m_axis_tstrb   = out_req.t.strb;
  assign m_axis_tkeep   = out_req.t.keep;
  assign m_axis_tlast   = out_req.t.last;
  assign m_axis_tid     = out_req.t.id;
  assign m_axis_tdest   = out_req.t.dest;
  assign m_axis_tuser   = out_req.t.user;
  assign out_rsp.tready = m_axis_tready;

  axi_stream_dw_upsizer #(
    .DataWidthIn          (DataWidthIn),
    .DataWidthOut         (DataWidthOut),
    .IdWidth              (IdWidth),
    .DestWidth            (DestWidth),
    .UserWidth            (UserWidth),
    .axi_stream_in_req_t  (s_in_req_t),
    .axi_stream_in_rsp_t  (s_in_rsp_t),
    .axi_stream_out_req_t (s_out_req_t),
    .axi_stream_out_rsp_t (s_out_rsp_t)
  ) i_axi_stream_dw_upsizer (
    .clk_i,
    .rst_ni,
    .in_req_i  (in_req),
    .in_rsp_o  (in_rsp),
    .out_req_o (out_req),
    .out_rsp_i (out_rsp)
  );

endmodule : axi_stream_dw_upsizer_wrapper
