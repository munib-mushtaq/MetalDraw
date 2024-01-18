//
//  ViewController.swift
//  MetalFramework
//
//  Created by Arslan Raza on 15/01/2024.
//

import UIKit
import QuartzCore
import SceneKit
import Metal
import MetalKit

class ViewController: UIViewController {

    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var dynamicNodes: [SCNNode] = []
    var timer: Timer!

    // Metal properties
    var metalDevice: MTLDevice!
    var metalView: MTKView!
    var metalCommandQueue: MTLCommandQueue!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize Metal
        setupMetal()

        // Setup the Scene
        setupScene()

        // Setup the Camera
        setupCamera()

        // Add a Floor
        setFloor()

        // Add Gesture Recognizer for Tapping
        addGestureRecognizer()
        
        // Add a Dynamic Node (Cube)
        addDynamicNode()
    }

    func setupMetal() {
        // Check if Metal is supported
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        self.metalDevice = metalDevice
        self.metalCommandQueue = metalDevice.makeCommandQueue()!

        // Create and configure Metal view
        metalView = MTKView(frame: view.bounds, device: metalDevice)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(metalView)

        // Set constraints for Metal view
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metalView.topAnchor.constraint(equalTo: view.topAnchor),
            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Set Metal view delegate
        metalView.delegate = self
    }

    func setupScene() {
        scnView = SCNView(frame: view.bounds)
        view.addSubview(scnView)

        scnScene = SCNScene()
        scnView.scene = scnScene
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
    }

    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        scnScene.rootNode.addChildNode(cameraNode)
    }

    func setFloor() {
        
        // Create and Add a Floor Node
        let floorGeometry = SCNFloor()
        floorGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
        scnView.backgroundColor = .darkGray
        let floorNode = SCNNode(geometry: floorGeometry)
        scnScene.rootNode.addChildNode(floorNode)

        // Attach a Static Physics Body to the Floor
        let staticBody = SCNPhysicsBody.static()
        floorNode.physicsBody = staticBody
    }

    @objc func addDynamicNode() {
        
        // Create and Add a Dynamic Node (Cube)
        let dynamicNode = SCNNode()
        let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        dynamicNode.geometry = boxGeometry
        dynamicNode.position = SCNVector3(x: 0, y: 10, z: 0)
        scnScene.rootNode.addChildNode(dynamicNode)

        // Attach a Dynamic Physics Body to the Cube
        let dynamicBody = SCNPhysicsBody.dynamic()
        dynamicBody.restitution = 0.5
        dynamicNode.physicsBody = dynamicBody
    }

    func addGestureRecognizer() {
        
        // Add Tap Gesture Recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let location = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: [:])

        if !hitResults.isEmpty {
            let result = hitResults.first!
            let node = result.node
            applyForce(to: node)
        } else {
            addDynamicNode()
        }
    }

    func applyForce(to node: SCNNode) {
        // Apply Upward Force to the Tapped Node
        let force = SCNVector3(x: 0, y: 10, z: 0)// Apply force upwards
        let position = SCNVector3(x: 0, y: 0, z: 0)// Position of the force (center of the node)
        node.physicsBody?.applyForce(force, at: position, asImpulse: true)
    }
}

// Metal View Delegate Extension
extension ViewController: MTKViewDelegate {
    func draw(in view: MTKView) {
        // Metal drawing logic goes here
        // Use metalCommandQueue to encode and commit rendering commands
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle Metal view size changes if needed
    }
}
