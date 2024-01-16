//
//  MetalRenderer.swift
//  MetalFramework
//
//  Created by Arslan Raza on 16/01/2024.
//

import Foundation
import MetalKit

class MetalRenderer: NSObject {
    //MARK: - Properties -
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    var vertices: [Float] = [
        -1, 1, 0,
        -1, -1, 0,
         1, -1, 0,
         1, 1, 0,
    ]
    
    var indices: [UInt16] =
    [
        0, 1, 2,
        2, 3, 0,
    ]
    
    
    //MARK: - Init -
    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()!
        super.init()
        buildModel()
        buildPipeLineState()
    }
    
    
    //MARK: - Methods -
    private func buildModel() {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Float>.size,
                                         options: [])
        
        indexBuffer = device.makeBuffer(bytes: indices,
                                         length: indices.count * MemoryLayout<UInt16 >.size,
                                         options: [])
    }
    
    private func buildPipeLineState() {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "fragment_shader")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as Error {
            NSLog("""
        Something happened:
        \(error)
        
        \(error.localizedDescription)
        """)
        }
    }
    
}


extension MetalRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let pipelineState = pipelineState,
              let indexBuffer = indexBuffer,
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            NSLog("Could not instantiate Metal command buffer.")
            return
        }
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            NSLog("Could not instantiate Metal command encoder.")
            return
        }
        
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer,
                                        offset: 0,
                                        index: 0)
//        commandEncoder.drawPrimitives(type: .triangle,
//                                       vertexStart: 0,
//                                       vertexCount: vertices.count)
        commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
