//
//  ViewController.swift
//  MetalApp2
//
//  Created by miyazawaryohei on 2020/09/23.
//

import UIKit
import MetalKit

class ViewController: UIViewController,MTKViewDelegate{
    
    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!
    
    private var texture: MTLTexture!
    //頂点座標を定義（ここでは画面全体を指定）
    private let vertexData: [Float] = [
        -1, -1, 0, 1,
        1, -1, 0, 1,
        -1,  1, 0, 1,
        1,  1, 0, 1
    ]
    private var textureData: [Float] = [
        0,1,
        1,1,
        0,0,
        1,0
    ]
    private var vertexBuffer: MTLBuffer!
    private var vertexBuffer2: MTLBuffer!
    private var renderPipeline: MTLRenderPipelineState!
    private let renderPassDescriptor = MTLRenderPassDescriptor()
    
    
    @IBOutlet var mtkView: MTKView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMetal()
        
        loadTexture()
        
        makeBuffer()
        
        //パイプラインの作成
        guard let library = device.makeDefaultLibrary() else {fatalError()}
        let descriptor = MTLRenderPipelineDescriptor()
        
        descriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        //レンダリング先のカラー関連の設定を指定する。その中でもpixelFormatプロバティの設定は必須
        descriptor.colorAttachments[0].pixelFormat = texture.pixelFormat
        //            .bgra8Unorm
        renderPipeline = try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    func setupMetal(){
        commandQueue = device.makeCommandQueue()
        mtkView.device = device
        mtkView.delegate = self
    }
    
    func loadTexture(){
        // MTKTextureLoaderを初期化
        let textureLoader = MTKTextureLoader(device: device)
        // テクスチャをロード
        texture = try! textureLoader.newTexture(
            name: "image",
            scaleFactor: view.contentScaleFactor,
            bundle: nil)
        mtkView.colorPixelFormat = texture.pixelFormat
    }
    
    func makeBuffer(){
        var size = vertexData.count * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: size)
        
        size = textureData.count * MemoryLayout<Float>.size
        vertexBuffer2 = device.makeBuffer(bytes: textureData, length: size)
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {return}
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {fatalError()}
        //MTLRenderPassColorAttachmentDescriptorクラスはグラフィックスレンダリングにより生成されるピクセルデータの色値の出力先を記述するためのディスクリプタ
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        // エンコーダ生成
        let renderEncoder =
            commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        guard let renderPipeline = renderPipeline else {fatalError()}
        renderEncoder.setRenderPipelineState(renderPipeline)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(vertexBuffer2, offset: 0, index: 1)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
}

