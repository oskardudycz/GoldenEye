﻿using System;
using System.Linq.Expressions;
using System.Runtime.Serialization;
using GoldenEye.Extensions.Basic;
using GoldenEye.Utils.Lambda;

namespace GoldenEye.Utils.Localization;

[Serializable]
[DataContract]
public class ResourceQualifiedKey
{
    private Type _resourceType;

    public ResourceQualifiedKey()
    {
    }

    public ResourceQualifiedKey(Type resourceType, string resourceId)
    {
        ResourceType = resourceType;
        ResourceId = resourceId;
    }

    public Type ResourceType
    {
        get
        {
            if (_resourceType == null && !ResourceTypeString.IsNullOrEmpty())
                _resourceType = Type.GetType(ResourceTypeString);

            return _resourceType;
        }
        set
        {
            _resourceType = value;

            ResourceTypeString = _resourceType.SafeGet(t => t.AssemblyQualifiedName);
        }
    }

    [DataMember] private string ResourceTypeString { get; set; }

    [DataMember] public string ResourceId { get; set; }

    public static ResourceQualifiedKey For<TResource>(Expression<Func<TResource, object>> member)
    {
        return new ResourceQualifiedKey(typeof(TResource), PropertyName.For(member));
    }

    public static ResourceQualifiedKey For<TResource>(Expression<Func<object>> member)
    {
        return new ResourceQualifiedKey(typeof(TResource), PropertyName.For(member));
    }

    public static ResourceQualifiedKey For<TResource>(string resourceId)
    {
        return new ResourceQualifiedKey(typeof(TResource), resourceId);
    }
}