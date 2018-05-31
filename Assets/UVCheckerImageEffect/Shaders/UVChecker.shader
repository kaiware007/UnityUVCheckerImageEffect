Shader "Hidden/UVChecker"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[KeywordEnum(ANGLE0, ANGLE90, ANGLE180, ANGLE270)] _ROTATEFLAG("Rotation", Float) = 0
		[Toggle] _FLIP_X("Flip X", Float) = 0
		[Toggle] _FLIP_Y("Flip Y", Float) = 0
		[KeywordEnum(DRAWMODE_HUE, DRAWMODE_CIRCLE, DRAWMODE_CHECKER)] _DRAW_MODE("Drae Mode", Float) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile _ROTATEFLAG_ANGLE0 _ROTATEFLAG_ANGLE90 _ROTATEFLAG_ANGLE180 _ROTATEFLAG_ANGLE270
			#pragma multi_compile _DRAWMODE_HUE _DRAWMODE_CIRCLE _DRAWMODE_CHECKER
			#pragma shader_feature _ _FLIP_X_ON
			#pragma shader_feature _ _FLIP_Y_ON

			#include "UnityCG.cginc"
			#include "PhotoshopMath.cginc"

			float mod(float x, float y)
			{
			  return x - y * floor(x/y);
			}

			// ---- 8< ---- GLSL Number Printing - @P_Malin ---- 8< ----
			// Creative Commons CC0 1.0 Universal (CC-0) 
			// https://www.shadertoy.com/view/4sBSWW

			float DigitBin( const int x )
			{
				return x == 0 ? 480599.0 : x == 1 ? 139810.0 : x == 2 ? 476951.0 : x == 3 ? 476999.0 : x == 4 ? 350020.0 : x == 5 ? 464711.0 : x == 6 ? 464727.0 : x == 7 ? 476228.0 : x == 8 ? 481111.0 : x == 9 ? 481095.0 : 0.0;
			}

			// ---- 8< -------- 8< -------- 8< -------- 8< ----
			float PrintValueInt(float2 fragCoord, float2 fontSize, int value, int maxDigits)
			{
				float gridNo = 0;
				float2 uv = (fragCoord.xy) * fontSize;
				if ((uv.x < 0.0) || (uv.x >= 1.0)) return 0.0;

				int index = (int)max((int)(maxDigits - 1) - (int)trunc(frac(uv.x) * maxDigits), 0);

				int l = (value > 0) ? log10(value) : 0;
				if (l < index) return 0;

				int p = (int)trunc(pow(10, index));

				gridNo = DigitBin(int(floor(mod((float)value / p, 10.0))));

				return floor(mod((gridNo / pow(2.0, floor(frac(uv.x * maxDigits) * 4.0) + (floor(uv.y * 5.0) * 4.0))), 2.0));
			}

			float PrintDot(float2 fragCoord, float2 fontSize)
			{
				float2 uv = (fragCoord.xy) * fontSize;
				if ((uv.x < 0.0) || (uv.x >= 1.0)) return 0.0;
				float gridNo = 2.0;

				return floor(mod((gridNo / pow(2.0, floor(frac(uv.x) * 4.0) + (floor(uv.y * 5.0) * 4.0))), 2.0));
			}

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			half _HueMin;
			half _HueMax;
			int _DivNumX;
			int _DivNumY;
			half2 _GridWidth;
			
			float box(float2 _st, float2 _size){
				_size = float2(0.5, 0.5) - _size * 0.5;
				float2 uv = smoothstep(_size, _size + float2(1e-4, 1e-4), _st);
				uv *= smoothstep(_size, _size + float2(1e-4, 1e-4), float2(1.0, 1.0) - _st);
				return uv.x * uv.y;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				half2 uv = i.uv.xy;

				// Flip
#ifdef _FLIP_X_ON
				uv.x = 1.0 - uv.x;
#endif
#ifdef _FLIP_Y_ON
				uv.y = 1.0 - uv.y;
#endif

				// Rotation
				float2 uv2 = uv;
#ifdef _ROTATEFLAG_ANGLE90 
				uv2.x = uv.y;
				uv2.y = 1.0 - uv.x;
#elif _ROTATEFLAG_ANGLE180 
				uv2 = 1.0 - uv;
#elif _ROTATEFLAG_ANGLE270
				uv2.x = 1.0 - uv.y;
				uv2.y = uv.x;
#endif
				float2 tile = half2(_DivNumX, _DivNumY);
				half2 uv_tiling = frac(uv2 * tile);
				half2 uvTilePos = floor(uv2 * tile);

				half3 hsv = frac(half3(lerp(_HueMin, _HueMax, lerp(0,1, floor(uv2.x * tile.x) / tile.x)), lerp(0.2, 1, floor(uv2 * tile) / tile))); 
				float gridLine = 1 - box(uv_tiling, _GridWidth);

				float2 fontSize = float2(3, 3);
				int maxDigitX = (_DivNumX > 0) ? log10(_DivNumX) + 1 : 1;
				int maxDigitY = (_DivNumY > 0) ? log10(_DivNumY) + 1 : 1;
				int maxDigit = max(maxDigitX, maxDigitY);

				float gridNoX = PrintValueInt(uv_tiling - float2(0.05, 0.05), fontSize, uvTilePos.x, maxDigit);
				float gridNoY = PrintValueInt(uv_tiling - float2(0.65, 0.05), fontSize, uvTilePos.y, maxDigit);

				float gridDot = PrintDot(uv_tiling - float2(0.5 - 0.025, 0.05), float2(fontSize.x * maxDigit, fontSize.y));

				float gridNo = saturate(gridNoX + gridNoY + gridDot);

#ifdef _DRAWMODE_HUE
				fixed4 gridCol = fixed4(hsv2rgb(hsv), 1);
				return lerp(lerp(gridCol, fixed4(1,1,1,1), gridLine), fixed4(1,1,1,1), gridNo);
#elif _DRAWMODE_CIRCLE
				fixed circleLen = length(uv_tiling - float2(0.5, 0.5));
				fixed4 gridCol = (circleLen <= 0.5) ? circleLen >= 0.45 ? fixed4(1,1,1,1) : fixed4(0,0,0,0) : fixed4(0,0,0,0);

				return lerp(gridCol, fixed4(1,1,1,1), gridLine);
#elif _DRAWMODE_CHECKER
				int2 gg = (floor(uv2 * tile));
				float grco = (gg.x + gg.y) % 2;

				fixed4 gridCol = lerp(fixed4(1,0,0,1), fixed4(0,0,1,1), grco);
				return lerp(lerp(gridCol, fixed4(1,1,1,1), gridLine), fixed4(1,1,1,1), gridNo);
#else
				fixed4 gridCol = fixed4(0,0,0,1);
				return lerp(gridCol, fixed4(1,1,1,1), gridLine);
#endif
			}
			ENDCG
		}
	}
}
