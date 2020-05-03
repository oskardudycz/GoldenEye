using System;
using System.Globalization;
using System.Runtime.Serialization;
using GoldenEye.Shared.Core.Context;
using GoldenEye.Shared.Core.Objects.Requests;

namespace GoldenEye.Shared.Core.Validation.Requests
{
    [Obsolete]
    public class ValidatableRequestBase: ValidatableObjectBase, IRequest
    {
        [DataMember] public string RequesterBrowser = string.Empty;

        [DataMember] public string RequesterDNS = string.Empty;

        [DataMember] public string RequesterIP = string.Empty;

        protected ValidatableRequestBase()
        {
            //RequesterUserID = StaticManager.User.Id;
            RequesterCultureName = CultureInfo.CurrentCulture.Name;
            RequesterIP = UserContext.ClientIP;
            RequesterDNS = UserContext.ClientDNS;
            RequesterBrowser = UserContext.ClientBrowser;
        }

        //[DataMember(Order = 0)]
        //public Guid RequesterUserID { get; set; }

        [DataMember] public string RequesterCultureName { get; set; }
    }
}
