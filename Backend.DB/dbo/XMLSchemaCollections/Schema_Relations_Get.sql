CREATE XML SCHEMA COLLECTION [dbo].[Schema_Relations_Get]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
  <xsd:element name="Request">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="SortDescriptors" type="SortDescriptorCollection" minOccurs="0" />
            <xsd:element name="Paging" type="Paging" minOccurs="0" />
            <xsd:element name="PartFilter" type="RelationPartFilter" minOccurs="0" maxOccurs="3" />
          </xsd:sequence>
          <xsd:attributeGroup ref="BaseRequest_AG" />
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
  <xsd:attributeGroup name="BaseRequest_AG">
    <xsd:attribute name="BranchId" type="xsd:unsignedInt" />
    <xsd:attribute name="UserId" type="xsd:unsignedInt" use="required" />
    <xsd:attribute name="StatusS" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusP" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusW" type="xsd:unsignedInt" />
    <xsd:attribute name="GetFullColumnsData" type="xsd:boolean" default="false" />
    <xsd:attribute name="ExpandNestedValues" type="xsd:boolean" default="false" />
    <xsd:attribute name="AppDate" type="datetimeSQL" />
    <xsd:attribute name="RequestType" type="ProcedureEnum" use="required" />
  </xsd:attributeGroup>
  <xsd:complexType name="CompositeAttributesFilter_Type">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:element name="FilterDescriptor" maxOccurs="unbounded">
            <xsd:complexType>
              <xsd:complexContent>
                <xsd:restriction base="xsd:anyType">
                  <xsd:sequence />
                  <xsd:attribute name="AttributeTypeId" type="xsd:unsignedInt" use="required" />
                  <xsd:attribute name="Operator" type="CompareEnum" use="required" />
                  <xsd:attribute name="Value" type="xsd:string" use="required" />
                </xsd:restriction>
              </xsd:complexContent>
            </xsd:complexType>
          </xsd:element>
          <xsd:element name="CompositeFilterDescriptor" type="CompositeAttributesFilter_Type" minOccurs="0" maxOccurs="unbounded" />
        </xsd:sequence>
        <xsd:attribute name="LogicalOperator" type="LogicalOperatorEnum" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="Paging">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="PageIndex" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="PageSize" type="xsd:positiveInteger" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="RelationPartFilter">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:element name="CompositeFilterDescriptor" type="CompositeAttributesFilter_Type" />
        </xsd:sequence>
        <xsd:attribute name="Side" type="SidesEnum" />
        <xsd:attribute name="EntityType" type="EntityTypeEnum" />
        <xsd:attribute name="TypeId" type="xsd:unsignedInt" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="SortDescriptor">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="PropertyName" type="xsd:string" use="required" />
        <xsd:attribute name="Direction" type="SortDirection" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="SortDescriptorCollection">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence maxOccurs="unbounded">
          <xsd:element name="SortDescriptor" type="SortDescriptor" />
        </xsd:sequence>
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name="CompareEnum">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="Contains" />
      <xsd:enumeration value="DoesNotContain" />
      <xsd:enumeration value="EndsWith" />
      <xsd:enumeration value="IsContainedIn" />
      <xsd:enumeration value="IsEqualTo" />
      <xsd:enumeration value="IsGreaterThan" />
      <xsd:enumeration value="IsGreaterThanOrEqualTo" />
      <xsd:enumeration value="IsLessThan" />
      <xsd:enumeration value="IsLessThanOrEqualTo" />
      <xsd:enumeration value="IsNotContainedIn" />
      <xsd:enumeration value="IsNotEqualTo" />
      <xsd:enumeration value="StartsWith" />
      <xsd:enumeration value="IsNull" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="EntityTypeEnum">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="Branch" />
      <xsd:enumeration value="UnitType" />
      <xsd:enumeration value="DataType" />
      <xsd:enumeration value="StructureType" />
      <xsd:enumeration value="UnitOfMeasure" />
      <xsd:enumeration value="Dictionary" />
      <xsd:enumeration value="DictionaryEntry" />
      <xsd:enumeration value="AttributeType" />
      <xsd:enumeration value="RelationBaseType" />
      <xsd:enumeration value="RelationType" />
      <xsd:enumeration value="Role" />
      <xsd:enumeration value="Operation" />
      <xsd:enumeration value="User" />
      <xsd:enumeration value="UserGroup" />
      <xsd:enumeration value="Unit" />
      <xsd:enumeration value="Relation" />
      <xsd:enumeration value="Structure" />
      <xsd:enumeration value="Attribute" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="LogicalOperatorEnum">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="AND" />
      <xsd:enumeration value="OR" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="ProcedureEnum">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="Units_GetOfType" />
      <xsd:enumeration value="Units_Get" />
      <xsd:enumeration value="Units_Delete" />
      <xsd:enumeration value="Units_Save" />
      <xsd:enumeration value="Units_GetRelationsCount" />
      <xsd:enumeration value="Units_GetHistory" />
      <xsd:enumeration value="Relations_GetByIds" />
      <xsd:enumeration value="Relations_GetFurther" />
      <xsd:enumeration value="Relations_Get" />
      <xsd:enumeration value="Relations_GetOfType" />
      <xsd:enumeration value="Relations_Delete" />
      <xsd:enumeration value="Relations_Save" />
      <xsd:enumeration value="Relations_GetHistory" />
      <xsd:enumeration value="Branches_Get" />
      <xsd:enumeration value="Branches_Delete" />
      <xsd:enumeration value="Branches_Save" />
      <xsd:enumeration value="Branches_GetHistory" />
      <xsd:enumeration value="UnitTypes_Get" />
      <xsd:enumeration value="UnitTypes_GetByIds" />
      <xsd:enumeration value="UnitTypes_Delete" />
      <xsd:enumeration value="UnitTypes_Save" />
      <xsd:enumeration value="UnitTypes_GetHistory" />
      <xsd:enumeration value="StructureTypes_Get" />
      <xsd:enumeration value="StructureTypes_GetByIds" />
      <xsd:enumeration value="StructureTypes_Delete" />
      <xsd:enumeration value="StructureTypes_Save" />
      <xsd:enumeration value="StructureTypes_GetHistory" />
      <xsd:enumeration value="UnitTypes_Branches_Get" />
      <xsd:enumeration value="AttributeTypes_Get" />
      <xsd:enumeration value="AttributeTypes_Delete" />
      <xsd:enumeration value="AttributeTypes_Save" />
      <xsd:enumeration value="AttributeTypes_GetHistory" />
      <xsd:enumeration value="AttributeDataTypes_Get" />
      <xsd:enumeration value="AttributeDataTypes_Delete" />
      <xsd:enumeration value="AttributeDataTypes_Save" />
      <xsd:enumeration value="AttributeDataTypes_GetHistory" />
      <xsd:enumeration value="Dictionary_Get" />
      <xsd:enumeration value="Dictionary_GetByIds" />
      <xsd:enumeration value="Dictionary_GetValuesByAttributeId" />
      <xsd:enumeration value="Dictionary_Delete" />
      <xsd:enumeration value="Dictionary_Save" />
      <xsd:enumeration value="Dictionary_GetHistory" />
      <xsd:enumeration value="UnitsOfMeasure_Get" />
      <xsd:enumeration value="UnitsOfMeasure_GetHistory" />
      <xsd:enumeration value="UnitsOfMeasure_Delete" />
      <xsd:enumeration value="UnitsOfMeasure_Save" />
      <xsd:enumeration value="UnitsOfMeasure_GetHistory" />
      <xsd:enumeration value="RelationTypes_Get" />
      <xsd:enumeration value="RelationTypes_GetByIds" />
      <xsd:enumeration value="RelationTypes_Delete" />
      <xsd:enumeration value="RelationTypes_Save" />
      <xsd:enumeration value="RelationTypes_GetHistory" />
      <xsd:enumeration value="RelationBaseTypes_Get" />
      <xsd:enumeration value="RelationBaseTypes_GetHistory" />
      <xsd:enumeration value="Structures_GetOfType" />
      <xsd:enumeration value="Structures_GetByIds" />
      <xsd:enumeration value="Structures_Delete" />
      <xsd:enumeration value="Structures_Save" />
      <xsd:enumeration value="Structures_GetHistory" />
      <xsd:enumeration value="Attribute_GetHistory" />
      <xsd:enumeration value="Users_Get" />
      <xsd:enumeration value="User_IsAdminGuaranteed" />
      <xsd:enumeration value="User_IsLoginUnique" />
      <xsd:enumeration value="Users_Delete" />
      <xsd:enumeration value="Users_Save" />
      <xsd:enumeration value="Users_GetByLogin" />
      <xsd:enumeration value="Users_AreCredentialsValid" />
      <xsd:enumeration value="UserGroups_Get" />
      <xsd:enumeration value="UserGroups_Delete" />
      <xsd:enumeration value="UserGroups_Save" />
      <xsd:enumeration value="Roles_Get" />
      <xsd:enumeration value="Roles_Delete" />
      <xsd:enumeration value="Roles_Save" />
      <xsd:enumeration value="Operations_Get" />
      <xsd:enumeration value="Attributes_GetHistory" />
      <xsd:enumeration value="AttributeTypes_GetByUnitTypeAndOtherFilters" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="SidesEnum">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="Left" />
      <xsd:enumeration value="Right" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="SortDirection">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="Ascending" />
      <xsd:enumeration value="Descending" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="dateSQL">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="((000[1-9])|(00[1-9][0-9])|(0[1-9][0-9]{2})|([1-9][0-9]{3}))-((0[1-9])|(1[012]))-((0[1-9])|([12][0-9])|(3[01]))(Z?)" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="datetimeSQL">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="((000[1-9])|(00[1-9][0-9])|(0[1-9][0-9]{2})|([1-9][0-9]{3}))-((0[1-9])|(1[012]))-((0[1-9])|([12][0-9])|(3[01]))T(([01][0-9])|(2[0-3]))(:[0-5][0-9]){2}(\.[0-9]{1,3})?(Z?)" />
    </xsd:restriction>
  </xsd:simpleType>
</xsd:schema>';

