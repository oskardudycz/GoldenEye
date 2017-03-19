using GoldenEye.Shared.Core.Context;
using GoldenEye.Shared.Core.Objects.Requests;
using System.Runtime.Serialization;

namespace GoldenEye.Shared.Core.Validation.Requests
{
    public class ValidatableRequestBase : ValidatableObjectBase, IRequest
    {
        protected ValidatableRequestBase()
        {
            //RequesterUserID = StaticManager.User.Id;
            RequesterCultureName = System.Threading.Thread.CurrentThread.CurrentCulture.Name;
            RequesterIP = UserContext.ClientIP;
            RequesterDNS = UserContext.ClientDNS;
            RequesterBrowser = UserContext.ClientBrowser;
        }

        //[DataMember(Order = 0)]
        //public Guid RequesterUserID { get; set; }

        [DataMember]
        public string RequesterCultureName { get; set; }

        [DataMember]
        public string RequesterIP = string.Empty;

        [DataMember]
        public string RequesterDNS = string.Empty;

        [DataMember]
        public string RequesterBrowser = string.Empty;
    }
}
