using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent(typeof(Camera))]
public abstract class CustomImageEffectBase : MonoBehaviour
{
    #region Fields

    private Material m_Material;

    #endregion

    #region Properties

    public abstract string ShaderName { get; }

    public Shader shader
    {
        get
        {
            if (m_Shader == null)
            {
                m_Shader = Shader.Find(ShaderName);
            }

            return m_Shader;
        }
    }
    [SerializeField, HideInInspector]
    private Shader m_Shader;

    public Material material
    {
        get
        {
            if (m_Material == null)
                m_Material = CheckShaderAndCreateMaterial(shader);

            return m_Material;
        }
    }
    #endregion

    #region Messages

    protected virtual void OnEnable()
    {
        if (!IsSupported(shader, true, false, this))
            enabled = false;
    }

    private void OnDisable()
    {
        if (m_Material != null)
            DestroyImmediate(m_Material);

        m_Material = null;
    }

    protected virtual void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        UpdateMaterial();

        Graphics.Blit(source, destination, m_Material);
    }

    #endregion

    #region Methods

    protected abstract void UpdateMaterial();

    public static bool IsSupported(Shader s, bool needDepth, bool needHdr, MonoBehaviour effect)
    {
#if UNITY_EDITOR
        // Don't check for shader compatibility while it's building as it would disable most effects
        // on build farms without good-enough gaming hardware.
        if (!BuildPipeline.isBuildingPlayer)
        {
#endif
            if (s == null || !s.isSupported)
            {
                Debug.LogWarningFormat("Missing shader for image effect {0}", effect);
                return false;
            }

#if UNITY_5_5_OR_NEWER
            if (!SystemInfo.supportsImageEffects)
#else
                if (!SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTextures)
#endif
            {
                Debug.LogWarningFormat("Image effects aren't supported on this device ({0})", effect);
                return false;
            }

            if (needDepth && !SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.Depth))
            {
                Debug.LogWarningFormat("Depth textures aren't supported on this device ({0})", effect);
                return false;
            }

            if (needHdr && !SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf))
            {
                Debug.LogWarningFormat("Floating point textures aren't supported on this device ({0})", effect);
                return false;
            }
#if UNITY_EDITOR
        }
#endif

        return true;
    }

    public static Material CheckShaderAndCreateMaterial(Shader s)
    {
        if (s == null || !s.isSupported)
            return null;

        var material = new Material(s);
        material.hideFlags = HideFlags.DontSave;
        return material;
    }
    #endregion

}