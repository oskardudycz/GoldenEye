using System;
using System.Collections.Generic;
using System.IO;
using System.Xml.Serialization;
using Backend.Business.Context;
using Shared.Core.Extensions;

namespace Backend.Business.Utils.Serialization
{
    public class TaskXmlSerializer
    {
        public string Serialize(TaskSaveRequest obj)
        {
            var serializer = new XmlSerializer(typeof(TaskSaveRequest), new[] { typeof(Val<int>), typeof(Val<string>), typeof(ValDateTime), typeof(ValDictionary) });

            var ns = new XmlSerializerNamespaces();
            ns.Add("xsi", "http://www.w3.org/2001/XMLSchema-instance");
            ns.Add("xsd", "http://www.w3.org/2001/XMLSchema");


            using (var writer = new StringWriter())
            {
                serializer.Serialize(writer, obj, ns);

                var result = writer.GetStringBuilder().ToString().Replace("<?xml version=\"1.0\" encoding=\"utf-16\"?>", string.Empty).Trim();

                return result;
            }
        }

        public Response<SaveValue> Deserialize(string xml)
        {
            var serializer = new XmlSerializer(typeof(Response<SaveValue>));

            using (var reader = new StringReader(xml))
            {
                var result = (Response<SaveValue>)serializer.Deserialize(reader);

                return result;
            }
        }
    }

    [XmlRoot("Request")]
    public class TaskSaveRequest
    {
        [XmlElement("Unit")]
        public TaskXml Task { get; set; }

        [XmlAttribute]
        public int UserId { get; set; }

        [XmlAttribute]
        public int StatusS
        {
            get { return 0; }
            set { }
        }

        [XmlAttribute]
        public int StatusP
        {
            get { return 0; }
            set { }
        }

        [XmlAttribute]
        public int StatusW
        {
            get { return 0; }
            set { }
        }

        [XmlIgnore]
        public DateTime AppDate { get; set; }


        [XmlAttribute("AppDate")]
        public string AppDateText
        {
            get { return AppDate.ToUTCTime(); }
        }

        [XmlAttribute]
        public string RequestType
        {
            get { return "Units_Save"; }
            set { }
        }

        public TaskSaveRequest()
        {

        }

        public TaskSaveRequest(int userId, Task task)
        {
            AppDate = DateTime.Now;
            Task = new TaskXml(task);
            UserId = userId;
        }
    }


    [XmlRoot("Response")]
    public class Response<T>
    {
        [XmlElement("Result")]
        public Result<T> Result { get; set; }
        //<?xml version="1.0" encoding="utf-8"?><Response ResponseType="Units_Save"><Result><Value><Ref Id="1" EntityType="Unit"/></Value></Result></Response>
    }

    public class Result<T>
    {
        [XmlElement("Value")]
        public ResultValue<T> Value { get; set; }

        [XmlElement("Error")]
        public ResponseError Error { get; set; }
    }

    public class ResultValue<T>
    {
        [XmlElement("Ref")]
        public T Ref { get; set; }
    }

    public class ResponseError
    {
        [XmlAttribute]
        public string ErrorMessage { get; set; }
    }

    public class SaveValue
    {
        [XmlAttribute]
        public int Id { get; set; }
    }


    [XmlRoot("Unit")]
    public class TaskXml
    {
        public TaskXml()
        {

        }

        public TaskXml(Task obj)
        {
            Id = obj.Id;
            LastModifiedOn = obj.ModificationDate.ToUTCTime();
            Name = obj.Name;


            Attributes = new List<TaskAttributeXml>();

            if (obj.CustomerId.HasValue)
                Attributes.Add(new TaskAttributeXml(68, 0, new ValDictionary(13, obj.CustomerId.Value), LastModifiedOn));
            if (obj.Color.HasValue)
                Attributes.Add(new TaskAttributeXml(69, 0, new Val<int>(obj.Color.Value), LastModifiedOn));

            Attributes.Add(new TaskAttributeXml(70, 0, new ValDateTime(obj.Date), LastModifiedOn));

            if (!string.IsNullOrEmpty(obj.Number))
                Attributes.Add(new TaskAttributeXml(71, 0, new Val<string>(obj.Number), LastModifiedOn));
            if (obj.TypeId.HasValue)
                Attributes.Add(new TaskAttributeXml(72, 0, new ValDictionary(14, obj.TypeId.Value), LastModifiedOn));
            if (obj.IsInternal.HasValue)
                Attributes.Add(new TaskAttributeXml(73, 0, new ValDictionary(2, obj.IsInternal.Value ? 1 : 2), LastModifiedOn));
            if (obj.Amount.HasValue)
                Attributes.Add(new TaskAttributeXml(74, 0, new Val<int>(obj.Amount.Value), LastModifiedOn));
            if (obj.PlannedTime.HasValue)
                Attributes.Add(new TaskAttributeXml(75, 0, new Val<int>(obj.PlannedTime.Value), LastModifiedOn));
            if (obj.PlannedStartDate.HasValue)
                Attributes.Add(new TaskAttributeXml(76, 0, new ValDateTime(obj.PlannedStartDate.Value), LastModifiedOn));
            if (obj.PlannedEndDate.HasValue)
                Attributes.Add(new TaskAttributeXml(77, 0, new ValDateTime(obj.PlannedEndDate.Value), LastModifiedOn));
            if (obj.Color.HasValue)
                Attributes.Add(new TaskAttributeXml(78, 0, new Val<int>(obj.Color.Value), LastModifiedOn));
            if (obj.PlanningDate.HasValue)
                Attributes.Add(new TaskAttributeXml(79, 0, new ValDateTime(obj.PlanningDate.Value), LastModifiedOn));
            if (!string.IsNullOrEmpty(obj.Description))
                Attributes.Add(new TaskAttributeXml(80, 0, new Val<string>(obj.Description), LastModifiedOn));
        }

        [XmlElement("Attribute")]
        public List<TaskAttributeXml> Attributes { get; set; }

        [XmlAttribute]
        public int TypeId
        {
            get { return 19; }
            set { }
        }

        [XmlAttribute]
        public int Version
        {
            get { return 0; }
            set { }
        }

        [XmlAttribute]
        public string Name { get; set; }

        [XmlAttribute]
        public int Id { get; set; }

        [XmlAttribute]
        public string LastModifiedOn { get; set; }
    }

    [XmlType("Attribute")]
    public class TaskAttributeXml
    {
        public TaskAttributeXml()
        {

        }
        public TaskAttributeXml(int typeId, int uiOrder, object value, string lastModifiedOn)
        {
            TypeId = typeId;
            LastModifiedOn = lastModifiedOn;
            UIOrder = uiOrder;
            Value = value;
        }

        [XmlAttribute]
        public int Id
        {
            get { return 0; }
            set { }
        }

        [XmlAttribute]
        public int TypeId { get; set; }

        [XmlAttribute]
        public int Priority
        {
            get { return 0; }
            set { }
        }

        [XmlElement]
        [XmlElement("ValInt", Type = typeof(Val<int>))]
        [XmlElement("ValString", Type = typeof(Val<string>))]
        [XmlElement("ValDatetime", Type = typeof(ValDateTime))]
        [XmlElement("ValDictionary", Type = typeof(ValDictionary))]
        public object Value { get; set; }

        [XmlAttribute]
        public int UIOrder { get; set; }

        [XmlAttribute]
        public string LastModifiedOn { get; set; }
    }

    public class Val<T>
    {
        public Val()
        {

        }

        public Val(T val)
        {
            Value = val;
        }

        [XmlAttribute]
        public T Value { get; set; }
    }

    public class ValDateTime : Val<string>
    {
        public ValDateTime()
        {

        }

        public ValDateTime(DateTime val)
        {
            Value = val.ToUTCTime();
        }
    }

    public class ValDictionary
    {
        public ValDictionary()
        {

        }

        public ValDictionary(int id, int elementId)
        {
            Id = id;
            ElementId = elementId;
        }

        [XmlAttribute]
        public int Id { get; set; }

        [XmlAttribute]
        public int ElementId { get; set; }
    }
}