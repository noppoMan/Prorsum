//
//  Net.swift
//  Prorsum
//
//  Created by Yuki Takei on 2016/11/27.
//
//

#if os(Linux)
    import Glibc
    let sys_off_t = Glibc.off_t()
    let sys_bind = Glibc.bind
    let sys_accept = Glibc.accept
    let sys_listen = Glibc.listen
    let sys_connect = Glibc.connect
    let sys_close = Glibc.close
    let sys_socket = Glibc.socket
    let sys_recv = Glibc.recv
    let sys_send = Glibc.send
    let sys_recvfrom = Glibc.recvfrom
    let sys_sendto = Glibc.sendto
    
    let SOCK_NOSIGNAL = Glibc.MSG_NOSIGNAL
    let SOCK_STREAM = Int32(Glibc.SOCK_STREAM.rawValue)
    let SOCK_DGRAM = Int32(Glibc.SOCK_DGRAM.rawValue)
    let SOCK_SEQPACKET = Int32(Glibc.SOCK_SEQPACKET.rawValue)
    let SOCK_RAW = Int32(Glibc.SOCK_RAW.rawValue)
    let SOCK_RDM = Int32(Glibc.SOCK_RDM.rawValue)
    let SOCK_MAXADDRLEN: Int32 = 255
    let IPPROTO_TCP = Int32(Glibc.IPPROTO_TCP)
    let IPPROTO_UDP = Int32(Glibc.IPPROTO_UDP)
#else
    import Darwin
    let sys_off_t = Darwin.off_t()
    let sys_bind = Darwin.bind
    let sys_accept = Darwin.accept
    let sys_listen = Darwin.listen
    let sys_connect = Darwin.connect
    let sys_close = Darwin.close
    let sys_socket = Darwin.socket
    let sys_recv = Darwin.recv
    let sys_send = Darwin.send
    let sys_recvfrom = Darwin.recvfrom
    let sys_sendto = Darwin.sendto
    
    let SOCK_NOSIGNAL = Darwin.SO_NOSIGPIPE
    let SOCK_STREAM = Darwin.SOCK_STREAM
    let SOCK_DGRAM = Darwin.SOCK_DGRAM
    let SOCK_SEQPACKET = Darwin.SOCK_SEQPACKET
    let SOCK_RAW = Darwin.SOCK_RAW
    let SOCK_RDM = Darwin.SOCK_RDM
    let IPPROTO_TCP = Darwin.IPPROTO_TCP
    let IPPROTO_UDP = Darwin.IPPROTO_UDP
    let SOCK_MAXADDRLEN = Darwin.SOCK_MAXADDRLEN
#endif

public typealias Byte = UInt8
public typealias Bytes = [Byte]

