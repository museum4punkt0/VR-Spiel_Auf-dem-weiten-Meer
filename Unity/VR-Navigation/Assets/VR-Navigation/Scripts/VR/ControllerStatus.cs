using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;
using Valve.VR;

[RequireComponent(typeof(Text))]
public class ControllerStatus : MonoBehaviour
{
    private Text text;
    [SerializeField] int updateDelay = 1;
    float lastupdate = int.MinValue;

    List<uint> connectedDevices = new List<uint>();

    void Awake()
    {
        text = GetComponent<Text>();
        if (SteamVR.instance == null)
        {
            text.enabled = false;
            enabled = false;
        }
        else
        {
            UpdateConnectedDevices();
        }
    }

    private void OnDeviceConnected(int deviceId, bool connected)
    {
        Debug.Log($"{this}: device connected {deviceId}, {connected}", this);
        uint deviceIndex = (uint)deviceId;
        UpdateDeviceList(deviceIndex, connected);
        lastupdate = int.MinValue; // force display update
    }

    private void UpdateDeviceList(uint deviceIndex, bool connected)
    {
        if (connected)
        {
            if (HasBattery(deviceIndex) && !connectedDevices.Contains(deviceIndex))
            {
                connectedDevices.Add(deviceIndex);
            }
        }
        else if (connectedDevices.Contains(deviceIndex))
        {
            connectedDevices.Remove(deviceIndex);
        }
    }

    private void ShowInfo(uint deviceIndex)
    {
        ETrackedDeviceClass deviceClass = OpenVR.System.GetTrackedDeviceClass(deviceIndex);
        ETrackedControllerRole role = GetDeviceRole(deviceIndex);
        bool hasbattery = HasBattery(deviceIndex);
        bool isCharging = IsCharging(deviceIndex);
        Debug.Log($"{this}:#{deviceIndex} {deviceClass}/{role} battery: {hasbattery} charging: {isCharging}", this);
    }

    private static bool IsCharging(uint deviceIndex)
    {
        ETrackedPropertyError error = default;
        return OpenVR.System.GetBoolTrackedDeviceProperty(deviceIndex, ETrackedDeviceProperty.Prop_DeviceIsCharging_Bool, ref error);
    }

    private static bool HasBattery(uint deviceIndex)
    {
        ETrackedPropertyError error = default;
        return OpenVR.System.GetBoolTrackedDeviceProperty(deviceIndex, ETrackedDeviceProperty.Prop_DeviceProvidesBatteryStatus_Bool, ref error);
    }

    private static ETrackedControllerRole GetDeviceRole(uint deviceIndex)
    {
        return OpenVR.System.GetControllerRoleForTrackedDeviceIndex(deviceIndex);
    }

    void OnEnable()
    {
        SteamVR_Events.DeviceConnected.AddListener(OnDeviceConnected);
    }

    void OnDisable()
    {
        SteamVR_Events.DeviceConnected.RemoveListener(OnDeviceConnected);
    }

    private void UpdateConnectedDevices()
    {
        for (uint i = 0; i < SteamVR.connected.Length; i++)
        {
            UpdateDeviceList(i, SteamVR.connected[i]);
        }
    }

    private static int BatteryLevelForDevice(uint deviceIndex)
    {
        float controller = SteamVR.instance.GetFloatProperty(ETrackedDeviceProperty.Prop_DeviceBatteryPercentage_Float, deviceIndex);
        int p = (int)(controller * 100);
        return p;
    }

    void Update()
    {
        if (SteamVR.instance != null)
        {
            float now = Time.time;
            if (now > lastupdate + updateDelay)
            {
                string display = "";
                if (connectedDevices.Count == 0)
                {
                    display = "No battery-powered controllers connected";
                }
                foreach (uint d in connectedDevices)
                {
                    display += $"Device #{d}: {BatteryLevelForDevice(d)}% ({GetDeviceRole(d)}) {(IsCharging(d) ? "Charging" : "")}\n";
                }
                text.text = display;
                lastupdate = now;
            }
        }
    }
}
