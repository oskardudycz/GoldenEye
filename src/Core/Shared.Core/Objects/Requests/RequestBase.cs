using System.Runtime.Serialization;
using GoldenEye.Shared.Core.Context;

namespace GoldenEye.Shared.Core.Objects.Requests
{
    [DataContract]
    public abstract class RequestBase: IRequest
    {
        protected RequestBase()
        {
            //RequesterUserID = StaticManager.User.Id;
            //RequesterCultureName = Thread.CurrentThread.CurrentCulture.Name;
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
