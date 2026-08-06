//
//  SplashSceneView.swift
//  Nova
//
//  Created by Wahab on 31/07/2026.
//

import SwiftUI
import SceneKit

struct SplashSceneView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = SCNScene()
        scnView.scene = scene
        scnView.backgroundColor = .black
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 8)
        scene.rootNode.addChildNode(cameraNode)
        
        let shape = SCNTorus(ringRadius: 1.2, pipeRadius: 0.4)
        shape.firstMaterial?.diffuse.contents = UIColor.systemPurple
        shape.firstMaterial?.metalness.contents = 0.8
        shape.firstMaterial?.roughness.contents = 0.2
        
        let shapeNode = SCNNode(geometry: shape)
        scene.rootNode.addChildNode(shapeNode)
        
        let rotate = CABasicAnimation(keyPath: "rotation")
        rotate.fromValue = NSValue(scnVector4: SCNVector4(1, 0, 0, 0))
        rotate.toValue = NSValue(scnVector4: SCNVector4(1, 0, 0, Float.pi * 2))
        rotate.duration = 6
        rotate.repeatCount = .infinity
        shapeNode.addAnimation(rotate, forKey: "rotate")
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
}

#Preview {
    SplashSceneView()
}
