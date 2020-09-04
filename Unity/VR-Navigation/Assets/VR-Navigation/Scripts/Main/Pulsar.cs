using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Pulsar : MonoBehaviour
{
    private Image image;
    [SerializeField] float startAlpha = default;
    [SerializeField] float endAlpha = default;
    [SerializeField] float frequency = default;

    void Awake()
    {
        image = GetComponent<Image>();
        frequency += Random.value * frequency / 10;
    }

    // Update is called once per frame
    void Update()
    {
        Color c = image.color;
        c.a = Mathf.Lerp(startAlpha, endAlpha, (Mathf.Sin(Time.time / frequency) + 1) / 2);
        image.color = c;
    }
}
