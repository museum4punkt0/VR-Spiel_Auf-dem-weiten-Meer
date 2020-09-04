using UnityEngine;
using NUnit.Framework;

namespace IJsfontein.AppUpdater
{
    public class AppUpdaterTest
    {
        private Version currentVersion;
        private BuildInfo buildInfo;

        [Test]
        public void HigherBuildAvailableTest()
        {
            Debug.Log(currentVersion);
            currentVersion.buildNumber = 0;
            Assert.IsTrue(Updater.IsDifferentVersion(buildInfo, currentVersion), "Updater should treat a higher build number as an available update");
        }

        [Test]
        public void EqualBuildAvailableTest()
        {
            currentVersion.buildNumber = 1;
            Assert.IsFalse(Updater.IsDifferentVersion(buildInfo, currentVersion), "Updater should not treat the same build number as an available update");
        }

        [Test]
        public void LowerBuildAvailableTest()
        {
            currentVersion.buildNumber = 2;
            Assert.IsTrue(Updater.IsDifferentVersion(buildInfo, currentVersion), "Updater should treat a lower build number as an available update");
        }

        [Test]
        public void OtherVersionNumberAvailableTest()
        {
            buildInfo.Version = "1.1";
            currentVersion.buildNumber = 1;
            Assert.IsTrue(Updater.IsDifferentVersion(buildInfo, currentVersion), "Updater should treat a different version string as an available update");
        }

        [Test]
        public void SameVersionNumberAvailableTest()
        {
            buildInfo.Version = "1.0";
            currentVersion.buildNumber = 1;
            Assert.IsFalse(Updater.IsDifferentVersion(buildInfo, currentVersion), "Updater should not treat the same version string as an available update");
        }
        
        [OneTimeSetUp]
        public void Setup()
        {
            currentVersion = ScriptableObject.CreateInstance<Version>();
            currentVersion.versionString = "1.0";
            buildInfo = new BuildInfo()
            {
                BuildNumber = 1,
                Version = "1.0"
            };
            Debug.LogFormat("Objects Set Up: {0}, {1}", currentVersion, buildInfo);
        }
    }
}