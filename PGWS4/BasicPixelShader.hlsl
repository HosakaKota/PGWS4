#include "BasicShaderHeader.hlsli"

#define TOON

float4 BasicPS(Output input) : SV_TARGET
{
	//光の向かうベクトル(平行光線ベクトル)
	float3 light = normalize(float3(1,-1,1));

	//ライトカラー(1,1,1で真っ白)
	float3 lightColor = float3(0.7, 0.7, 0.7);

	//ディフューズ計算
	float3 normal = normalize(input.normal.xyz);
	float diffuseB = saturate(dot(-light, normal));

	//光の反射ベクトル
	float3 refLight = reflect(light, normal);
	float specularB = pow(saturate(dot(refLight, -normalize(input.ray))), specular.a);
	//スフィアマップ用uv
	float2 sphereMapUV = normalize(input.vnormal).xy * float2(0.5, -0.5) + 0.5;

	//テクスチャカラー
	float4 texColor = tex.Sample(smp, input.uv);

#ifdef TOON
	float3 toonDif = toon.Sample(smpToon, float2(0, 1.0 - diffuseB)).rgb;
	float3 toonSpc = toon.Sample(smpToon, float2(0, 1.0 - specularB)).rgb;
	return float4(lightColor *//ライトカラー
		(texColor.rgb//テクスチャカラー
			* sph.Sample(smp, sphereMapUV).rgb//スフィアマップ(乗算)
			* (ambient + toonDif * diffuse.rgb)//環境光＋ディフューズ色
			+ spa.Sample(smp, sphereMapUV).rgb//スフィアマップ(加算)
			//+ specularB * specular.rgb)//スぺキュラ
			+ toonSpc * specular.rgb)
		, diffuse.a);//アルファ
#endif //TOON
}
