using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class DolphinSpawner : MonoBehaviour
{
    public int numSpawns = 3;
    public float delayBetween = 10;

    public GameObject activate;

    public void StartSpawning()
    {
        Spawn();
    }

    void Spawn()
    {
        activate.SetActive(true);
        if (numSpawns-- > 0)
        {
            DOVirtual.DelayedCall(delayBetween, Spawn);
        }
    }
}
