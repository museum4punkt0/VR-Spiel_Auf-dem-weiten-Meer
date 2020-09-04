using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class FogTweener : MonoBehaviour
{
    [SerializeField] Color[] colors = default;

    int current = 0;

    void Awake()
    {
        if (colors.Length > 0)
        {
            RenderSettings.fogColor = colors[current];
        }
    }

    public void TweenNext()
    {
        current++;
        Color nextColor = colors[current % colors.Length];
        Color currentColor = RenderSettings.fogColor;
        DOVirtual.Float(0, 1, 5, (f) =>
        {
            RenderSettings.fogColor = Color.Lerp(currentColor, nextColor, f);
        });
    }
}
