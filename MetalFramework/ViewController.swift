//
//  ViewController.swift
//  MetalFramework
//
//  Created by Arslan Raza on 15/01/2024.
//

import UIKit
import MetalKit

enum Color {
    static let defaultColor = MTLClearColor(red: 0.0, green: 0.4, blue: 0.41, alpha: 1.0)
}

class ViewController: UIViewController {
    var metalView: MTKView!
    var device : MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var constant = Constant()
    var time: Float = 0
    
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
        3, 2, 0,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let metalView = MTKView()
        
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.frame.size.height = self.view.frame.height
        metalView.frame.size.width = self.view.frame.width
        metalView.device = MTLCreateSystemDefaultDevice()
        device = metalView.device
        metalView.clearColor = Color.defaultColor
        commandQueue = device.makeCommandQueue()
        self.metalView = metalView
        metalView.delegate = self
        self.view.addSubview(self.metalView)
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
        } catch let error {
            NSLog("""
        Something happened:
        \(error)
        
        \(error.localizedDescription)
        """)
        }
    }
}

extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let pipelineState = pipelineState,
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
        time += 2 / Float(view.preferredFramesPerSecond)
        let animatedBy = abs(sin(time)/2 + 0.5)
        constant.animatedBy = animatedBy
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer,
                                       offset: 0,
                                       index: 0)
        
        commandEncoder.setVertexBytes(&constant, length: MemoryLayout<Constant>.stride, index: 1)
        commandEncoder.drawPrimitives(type: .triangleStrip,
                                      vertexStart: 0,
                                      vertexCount: vertices.count)
                    commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

struct Constant {
    var animatedBy: Float = 0.0
}
