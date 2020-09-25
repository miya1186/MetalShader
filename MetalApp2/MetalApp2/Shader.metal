//
//  Shader.metal
//  MetalApp2
//
//  Created by miyazawaryohei on 2020/09/23.
//

#include <metal_stdlib>
using namespace metal;

struct ColorInOut
{
    float4 position[[position]];
    //テクスチャ内における座標」(2次元)を保持するための要素
    float2 texCoords;
};

//冒頭のvertex 頂点シェーダの関数であることを宣言
vertex ColorInOut vertexShader(constant float4 *positions [[ buffer(0) ]],
                               constant float2 *texCoords [[ buffer(1) ]],
                               uint    vid       [[ vertex_id ]])
{
    ColorInOut out;
    out.position = positions[vid];
    out.texCoords = texCoords[vid];
    return out;
}
//冒頭のfragment フラグメントシェーダ関数であることを宣言
//第2引数の texture2d<T>型は2次元テクスチャを表し、Tはそれぞれの色値の型を示す
//同引数の修飾子 [[ texture(n) ]]に示した引数には、CPUプログラム側でMTLRenderCommandEncoderの setFragmentTexture(_:index:)メソッドでセットしたMTLTextureオブジェクトの内容が入ってくる
fragment float4 fragmentShader(ColorInOut in [[ stage_in ]],
                               texture2d<float> texture [[ texture(0) ]])
{
    //samplerという型の変数は「サンプラー」と呼ばれ、どのようにテクスチャデータにアクセスするかを定義する(今回はなにもしない)
    //サンプラーは引数から渡すこともできるが、今回のようにシェーダプログラム内で初期化する場合はconstexprと共に宣言する必要がある
    constexpr sampler colorSampler;
    //texture2d型のテクスチャは、第1引数にsamplerオブジェクトを、第2引数にテクスチャ座標を渡して、該当するピクセルのデータを取得することができる。第3引数のオフセットは省略可能。
    //引数から得たテクスチャデータから、samplerオブジェクトと、ColorInOut構造体に入っているテクスチャ座標を使用して、 該当するピクセル値の色値を取得
    float4 color = texture.sample(colorSampler, in.texCoords);
    //テクスチャから得た色値をそのまま出力
    return color;
    //フラグメントシェーダは単にテクスチャからピクセルの色値を取り出して画面の当該ピクセルの色として出力しており、その処理が画面全体のピクセルに行われるので、テクスチャ(画像)が画面に描画される
}
