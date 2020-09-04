using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Text))]
public class TimeDisplay : MonoBehaviour
{
    private readonly int updateDelay = 1;
    private Text text;
    private int lastupdate = int.MinValue;
    private float startTime;

    void Awake()
    {
        text = GetComponent<Text>();
    }

    void Start()
    {
        Reset();
    }

    public void Reset()
    {
        startTime = Time.time;
    }

    // Update is called once per frame
    void Update()
    {
        float now = Time.time - startTime;
        if (now > lastupdate + updateDelay)
        {
            int m = Mathf.FloorToInt(now / 60);
            int s = (int)now % 60;

            text.text = $"{m}:{s:00}";
        }
    }
}
