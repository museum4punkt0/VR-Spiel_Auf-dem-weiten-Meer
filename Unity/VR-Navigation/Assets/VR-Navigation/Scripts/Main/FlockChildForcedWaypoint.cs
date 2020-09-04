using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlockChildForcedWaypoint : FlockChild
{
    public Vector3 WayPoint { get; set; }
    public Vector3 SpawnPoint { get; set; }

    override public Vector3 findWaypoint()
    {
        return WayPoint; // just use the one set earlier
    }

    override public void Start()
    {
        base.Start();
        _thisT.position = SpawnPoint;
    }
}
