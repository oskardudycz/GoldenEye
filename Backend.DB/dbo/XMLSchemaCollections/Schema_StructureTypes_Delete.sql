CREATE XML SCHEMA COLLECTION [dbo].[Schema_StructureTypes_Delete]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
  <xsd:element name="Request" type="Request_Delete_BaseType" />
  <xsd:attributeGroup name="BaseRequest_AG">
    <xsd:attribute name="BranchId" type="xsd:unsignedInt" />
    <xsd:attribute name="UserId" type="xsd:unsignedInt" use="required" />
    <xsd:attribute name="StatusS" type="xsd:string" />
    <xsd:attribute name="StatusP" type="xsd:string" />
    <xsd:attribute name="StatusW" type="xsd:string" />
    <xsd:attribute name="GetFullColumnsData" type="xsd:boolean" fixed="false" />
    <xsd:attribute name="AppDate" type="xsd:date" />
    <xsd:attribute name="RequestType" type="ProcedureEnum_Type" use="required" />
  </xsd:attributeGroup>
  <xsd:complexType name="Ref">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="Id" type="xsd:unsignedInt" />
        <xsd:attribute name="EntityType" type="EntityType" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="Request_Delete_BaseType">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:element name="Ref" type="Ref" maxOccurs="unbounded" />
        </xsd:sequence>
        <xsd:attributeGroup ref="BaseRequest_AG" />
        <xsd:attribute name="IsSoftDelete" type="xsd:boolean" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name="EntityType">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="Branch" />
      <xsd:enumeration value="ObjectType" />
      <xsd:enumeration value="DataType" />
      <xsd:enumeration value="StructureType" />
      <xsd:enumeration value="UnitOfMeasure" />
      <xsd:enumeration value="Dictionary" />
      <xsd:enumeration value="DictionaryEntry" />
      <xsd:enumeration value="AttributeType" />
      <xsd:enumeration value="RelationBaseType" />
      <xsd:enumeration value="RelationType" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="ProcedureEnum_Type">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="Objects_GetOfType" />
      <xsd:enumeration value="Objects_Get" />
      <xsd:enumeration value="Objects_Delete" />
      <xsd:enumeration value="Objects_Save" />
      <xsd:enumeration value="Objects_GetRelationsCount" />
      <xsd:enumeration value="Relations_GetByIds" />
      <xsd:enumeration value="Relations_GetFuther" />
      <xsd:enumeration value="Relations_GetBy" />
      <xsd:enumeration value="Relations_Delete" />
      <xsd:enumeration value="Relations_Save" />
      <xsd:enumeration value="Branches_Get" />
      <xsd:enumeration value="Branches_Delete" />
      <xsd:enumeration value="Branches_Save" />
      <xsd:enumeration value="ObjectTypes_Get" />
      <xsd:enumeration value="ObjectTypes_GetByIds" />
      <xsd:enumeration value="ObjectTypes_Remove" />
      <xsd:enumeration value="ObjectTypes_Save" />
      <xsd:enumeration value="StructureTypes_Get" />
      <xsd:enumeration value="StructureTypes_GetByIds" />
      <xsd:enumeration value="StructureTypes_Delete" />
      <xsd:enumeration value="StructureTypes_Save" />
      <xsd:enumeration value="ObjectTypes_Branches_Get" />
      <xsd:enumeration value="AttributeTypes_Get" />
      <xsd:enumeration value="AttributeTypes_Remove" />
      <xsd:enumeration value="AttributeTypes_Save" />
      <xsd:enumeration value="AttributeDataTypes_Get" />
      <xsd:enumeration value="AttributeDataTypes_Delete" />
      <xsd:enumeration value="AttributeDataTypes_Save" />
      <xsd:enumeration value="Dictionary_GetHeaders" />
      <xsd:enumeration value="Dictionary_GetValuesByDicName" />
      <xsd:enumeration value="Dictionary_GetValuesByAttributeId" />
      <xsd:enumeration value="Dictionary_Delete" />
      <xsd:enumeration value="Dictionary_Save" />
      <xsd:enumeration value="UnitsOfMeasure_Get" />
      <xsd:enumeration value="UnitsOfMeasure_Delete" />
      <xsd:enumeration value="UnitsOfMeasure_Save" />
      <xsd:enumeration value="RelationTypes_Get" />
      <xsd:enumeration value="RelationTypes_GetByIds" />
      <xsd:enumeration value="RelationTypes_Dalete" />
      <xsd:enumeration value="RelationTypes_Save" />
      <xsd:enumeration value="RelationBaseTypes_Get" />
      <xsd:enumeration value="Structures_GetOfType" />
      <xsd:enumeration value="Structures_GetByIds" />
      <xsd:enumeration value="Structures_Delete" />
      <xsd:enumeration value="Structures_Save" />
      <xsd:enumeration value="RelationAttributes_Get" />
      <xsd:enumeration value="Attribute_GetHistory" />
      <xsd:enumeration value="Users_Get" />
      <xsd:enumeration value="User_IsAdminGuaranteed" />
      <xsd:enumeration value="User_IsNameUnique" />
      <xsd:enumeration value="Users_Delete" />
      <xsd:enumeration value="Users_Save" />
      <xsd:enumeration value="Users_GetByLogin" />
      <xsd:enumeration value="Users_IsAuthenticated" />
      <xsd:enumeration value="UserGroups_Get" />
      <xsd:enumeration value="UserGroups_Delete" />
      <xsd:enumeration value="UserGroups_Save" />
      <xsd:enumeration value="Roles_Get" />
      <xsd:enumeration value="Roles_Delete" />
      <xsd:enumeration value="Roles_Save" />
      <xsd:enumeration value="Operations_Get" />
    </xsd:restriction>
  </xsd:simpleType>
</xsd:schema>';

