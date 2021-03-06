Shader "TENKOKU/galaxy_shader" {
Properties {
	_SIntensity ("Star Intensity", Range(0.0,1.0)) = 1.0
	_GIntensity ("Galaxy Intensity", Range(0.0,1.0)) = 1.0
	_Color ("Main Color", Color) = (1,1,1,1)
	_GTex ("Galaxy Tex", 2D) = "white" {}
	_STex ("Star Detail Tex", 2D) = "white" {} 
	_CubeTex ("Cube Tex", Cube) = "white" {}
	_StarPerTex ("Star Perturbation", 2D) = "white" {}
	_perturbation ("Perturbation", Range(0.0,1.0)) = 1.0
}

SubShader {


	//Tags { "Queue"="Background-25"}
Tags { "Queue"="Background+1601"}
	//Blend SrcAlpha OneMinusSrcAlpha
	Blend One One
	//AlphaTest Greater .01
	//ColorMask RGB
	Cull Front
	Lighting Off
	ZWrite Off
	Fog {Mode Off}
	
	Offset 1,996000
	

	Pass {
		
		CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest nofog
		#include "UnityCG.cginc"

		sampler2D _GTex,_STex,_StarPerTex;
		samplerCUBE _CubeTex;

		fixed4 _Color;
		float _GIntensity, _SIntensity;
		float _tenkokuIsLinear;
		float4 _TenkokuAmbientColor;
		float _Tenkoku_AtmosphereDensity;
		float _Tenkoku_AmbientGI;

		float _useCube;
		float _useStar;
		float _useGlxy;
		float _perturbation;

		struct appdata_t {
			float4 vertex : POSITION;
			float3 texcoord : TEXCOORD0;
			float3 texcoord1 : TEXCOORD1;
			float3 normal : NORMAL;
		};

		struct v2f {
			float4 vertex : POSITION;
			float3 texcoord : TEXCOORD0;
			float3 texcoord1 : TEXCOORD1;
		};

		v2f vert (appdata_t v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.texcoord = v.texcoord;
			o.texcoord1 = v.normal;
			return o;
		}

		fixed4 frag (v2f i) : COLOR
		{

			//coordinates
			fixed2 coord = i.texcoord.xy;
			coord.y = 1.0-coord.y;
			fixed4 col = fixed4(0,0,0,1);

			//galaxy 2D spheremap
			if (_useCube == 0.0 && _useGlxy <= 1.0){
				fixed4 gtex = tex2D (_GTex, coord);
				col.rgb = lerp(half3(0,0,0),gtex.rgb * _GIntensity,_Color.a);
			}

			//galaxy cubemap
			if (_useCube == 1.0 && _useGlxy <= 1.0){
				fixed4 gCtex = texCUBE(_CubeTex, i.texcoord1);
				col.rgb = lerp(half3(0,0,0),gCtex.rgb * _GIntensity,_Color.a);
			}


			//star
			if (_useStar <= 1.0){
				fixed4 stex = tex2D (_STex, coord);
				fixed4 pert = tex2D(_StarPerTex,float2(coord.x,coord.y+_Time.x*0.15));
				col.rgb = col.rgb + lerp(half3(0,0,0),stex.rgb * 1.4 * _SIntensity,_Color.a) * lerp(1,pert.rgb,_perturbation);
			}
			
			//gamma
			half gammaFac = lerp(2.4,1.0,_tenkokuIsLinear);
			col.rgb *= gammaFac;

			//final
			col.a = (1.0-_TenkokuAmbientColor.r);
			col.a -= lerp(0.0,1.0,_Tenkoku_AtmosphereDensity*0.25);
			col.a = saturate(col.a);
			col.rgb *= col.a;


			return col;
		}
		ENDCG 
	}
}

Fallback Off

}