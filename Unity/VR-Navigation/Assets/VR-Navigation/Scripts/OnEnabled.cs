using DG.Tweening;
using UnityEngine;
using UnityEngine.Events;

public class OnEnabled : MonoBehaviour
{
    public UnityEvent onEnable;
    public UnityEvent onDisable;

    void OnEnable()
    {
        if (onEnable != null)
        {
            DOVirtual.DelayedCall(.01f, onEnable.Invoke);
        }
    }

    void OnDisable()
    {
        if (onDisable != null)
        {
            DOVirtual.DelayedCall(.01f, onDisable.Invoke);
        }
    }

}
