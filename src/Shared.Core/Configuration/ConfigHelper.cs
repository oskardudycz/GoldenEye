using System.Configuration;

namespace GoldenEye.Shared.Core.Configuration
{
    public class ConfigHelper
    {
        public static bool IsInTestMode
        {
            get
            {
                return GetSettingAsString("IsInTestMode") == "true";
            }
        }

        /// <summary>
        /// Returns the value of the configuration setting called ”settingName”
        /// from either web.config, or the Azure Role Environment.
        /// </summary>
        public static string GetSettingAsString(string settingName)
        {
            //    if (RoleEnvironment.IsAvailable)
            //        return RoleEnvironment.GetConfigurationSettingValue(settingName);

            if (ConfigurationManager.AppSettings[settingName] != null)
                return ConfigurationManager.AppSettings[settingName];

            return ConfigurationManager.ConnectionStrings[settingName] != null
                     ? ConfigurationManager.ConnectionStrings[settingName].ConnectionString
                     : null;
        }
    }
}