using Crest;
using UnityEngine;
using DG.Tweening;

public class QuietZoneTrigger : MonoBehaviour
{
    [SerializeField] ShapeGerstnerBatched waves = default;
    [Range(0f, 1f)]
    [SerializeField] float waveWeightInside = default;
    [Range(0f, 1f)]
    [SerializeField] float waveWeightOutside = default;
    [SerializeField] float tweenDuration = 5;

    void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            TweenWaveWeight(waveWeightInside);
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            TweenWaveWeight(waveWeightOutside);
        }
    }

    private void TweenWaveWeight(float waveWeight)
    {
        DOVirtual.Float(waves._weight, waveWeight, tweenDuration, (f) =>
        {
            waves._weight = f;
        });
    }
}
