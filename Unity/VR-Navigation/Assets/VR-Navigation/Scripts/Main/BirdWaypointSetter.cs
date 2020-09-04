using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(SphereCollider))]
public class BirdWaypointSetter : MonoBehaviour
{
    [SerializeField] SphereCollider spawnPoint = default;

    public void SetWaypointOnBird(Transform bird)
    {
        float radius = GetComponent<SphereCollider>().radius;
        FlockChildForcedWaypoint flockChild = bird.GetComponent<FlockChildForcedWaypoint>();
        if (flockChild)
        {
            flockChild.WayPoint = transform.position;
            flockChild.SpawnPoint = RandomPointInsideSpawnCollider();
        }
    }

    private Vector3 RandomPointInsideSpawnCollider()
    {
        return spawnPoint.transform.position + (Random.insideUnitSphere * spawnPoint.radius);
    }

    void OnTriggerEnter(Collider other)
    {
        Debug.Log($"{this} trigger enter {other}", this);
        FlockChildForcedWaypoint flockChild = other.GetComponentInParent<FlockChildForcedWaypoint>();
        if (flockChild)
        {
            flockChild.transform.position = RandomPointInsideSpawnCollider();
            flockChild.Flap(); // prevent it from floating without flapping
        }
    }
}
