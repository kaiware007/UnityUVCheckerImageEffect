using UnityEngine;

[ExecuteInEditMode]
public class UVChecker : CustomImageEffectBase {

    public enum RotateAngle
    {
        Angle0,
        Angle90,
        Angle180,
        Angle270
    }

    public Vector2Int divNum = new Vector2Int(8, 8);
    [Range(0,1)]
    public float hueMin = 0;
    [Range(0,1)]
    public float hueMax = 1;

    public Vector2 gridWidth = new Vector2(0.98f, 0.98f);

    public RotateAngle rotateAngle = RotateAngle.Angle0;
    public bool flipX = false;
    public bool flipY = false;

    public override string ShaderName
    {
        get
        {
            return "Hidden/UVChecker";
        }
    }

    private void OnValidate()
    {
        UpdateFadeMaskFlipRotation();
    }

    protected override void UpdateMaterial()
    {
        material.SetInt("_DivNumX", divNum.x);
        material.SetInt("_DivNumY", divNum.y);

        material.SetFloat("_HueMin", hueMin);
        material.SetFloat("_HueMax", hueMax);

        material.SetVector("_GridWidth", gridWidth);


    }
    public void UpdateFadeMaskFlipRotation()
    {
        switch (rotateAngle)
        {
            case RotateAngle.Angle0:
                material.EnableKeyword("_ROTATEFLAG_ANGLE0");

                material.DisableKeyword("_ROTATEFLAG_ANGLE90");
                material.DisableKeyword("_ROTATEFLAG_ANGLE180");
                material.DisableKeyword("_ROTATEFLAG_ANGLE270");
                break;
            case RotateAngle.Angle90:
                material.DisableKeyword("_ROTATEFLAG_ANGLE0");

                material.EnableKeyword("_ROTATEFLAG_ANGLE90");

                material.DisableKeyword("_ROTATEFLAG_ANGLE180");
                material.DisableKeyword("_ROTATEFLAG_ANGLE270");
                break;
            case RotateAngle.Angle180:
                material.DisableKeyword("_ROTATEFLAG_ANGLE0");
                material.DisableKeyword("_ROTATEFLAG_ANGLE90");

                material.EnableKeyword("_ROTATEFLAG_ANGLE180");

                material.DisableKeyword("_ROTATEFLAG_ANGLE270");
                break;
            case RotateAngle.Angle270:
                material.DisableKeyword("_ROTATEFLAG_ANGLE0");
                material.DisableKeyword("_ROTATEFLAG_ANGLE90");
                material.DisableKeyword("_ROTATEFLAG_ANGLE180");

                material.EnableKeyword("_ROTATEFLAG_ANGLE270");
                break;
        }

        if (flipX)
        {
            material.EnableKeyword("_FLIP_X_ON");
        }
        else
        {
            material.DisableKeyword("_FLIP_X_ON");
        }

        if (flipY)
        {
            material.EnableKeyword("_FLIP_Y_ON");
        }
        else
        {
            material.DisableKeyword("_FLIP_Y_ON");
        }
    }
}
