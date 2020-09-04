using UnityEngine;

public class BirdSpawner : MonoBehaviour
{
    [SerializeField] FlockController flockController = default;
    [SerializeField] int numberOfBirds = 10;
    [SerializeField] float spawnDelay = 2;
    private float lastSpawn = 0;

    void Update()
    {
        if (flockController._childAmount < numberOfBirds)
        {
            float now = Time.time;
            if (lastSpawn + spawnDelay < now)
            {
                lastSpawn = now;
                flockController._childAmount++;
            }
        }
    }
}
