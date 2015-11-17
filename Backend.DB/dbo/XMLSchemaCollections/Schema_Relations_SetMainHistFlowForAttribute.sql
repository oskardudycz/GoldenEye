CREATE XML SCHEMA COLLECTION [dbo].[Schema_Relations_SetMainHistFlowForAttribute]
    AS N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
  <xsd:element name="Request">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:extension base="Request_BaseType">
          <xsd:sequence>
            <xsd:element name="Attribute" type="Attribute" />
          </xsd:sequence>
          <xsd:attribute name="RelationId" type="xsd:unsignedInt" use="required" />
        </xsd:extension>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
  <xsd:attributeGroup name="Administratives_AG">
    <xsd:attribute name="IsArchive" type="xsd:boolean" default="false" />
    <xsd:attribute name="ArchivedFrom" type="datetimeSQL" />
    <xsd:attribute name="ArchivedBy" type="xsd:unsignedInt" />
    <xsd:attribute name="IsDeleted" type="xsd:boolean" default="false" />
    <xsd:attribute name="DeletedFrom" type="datetimeSQL" />
    <xsd:attribute name="DeletedBy" type="xsd:unsignedInt" />
    <xsd:attribute name="CreatedOn" type="datetimeSQL" />
    <xsd:attribute name="CreatedBy" type="xsd:unsignedInt" />
    <xsd:attribute name="LastModifiedOn" type="datetimeSQL" use="required" />
    <xsd:attribute name="LastModifiedBy" type="xsd:unsignedInt" />
  </xsd:attributeGroup>
  <xsd:attributeGroup name="Attribute_Type_Histories_AG">
    <xsd:attribute name="ChangeFrom" type="datetimeSQL" use="required" />
    <xsd:attribute name="ChangeTo" type="datetimeSQL" />
    <xsd:attribute name="EffectiveFrom" type="datetimeSQL" use="required" />
    <xsd:attribute name="EffectiveTo" type="datetimeSQL" />
    <xsd:attribute name="IsMainHistFlow" type="xsd:boolean" use="required" />
  </xsd:attributeGroup>
  <xsd:attributeGroup name="BaseRequest_AG">
    <xsd:attribute name="BranchId" type="xsd:unsignedInt" />
    <xsd:attribute name="UserId" type="xsd:unsignedInt" use="required" />
    <xsd:attribute name="StatusS" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusP" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusW" type="xsd:unsignedInt" />
    <xsd:attribute name="AppDate" type="datetimeSQL" use="required" />
    <xsd:attribute name="RequestType" type="ProcedureEnum" use="required" />
  </xsd:attributeGroup>
  <xsd:attributeGroup name="Histories_AG">
    <xsd:attribute name="ChangeFrom" type="datetimeSQL" />
    <xsd:attribute name="ChangeTo" type="datetimeSQL" />
    <xsd:attribute name="EffectiveFrom" type="datetimeSQL" />
    <xsd:attribute name="EffectiveTo" type="datetimeSQL" />
    <xsd:attribute name="IsMainHistFlow" type="xsd:boolean" default="true" />
    <xsd:attribute name="IsAlternativeHistory" type="xsd:boolean" default="false" />
  </xsd:attributeGroup>
  <xsd:attributeGroup name="Identifications_AG">
    <xsd:attribute name="Id" type="xsd:unsignedInt" use="required" />
    <xsd:attribute name="TypeId" type="xsd:unsignedInt" use="required" />
  </xsd:attributeGroup>
  <xsd:attributeGroup name="Statuses_AG">
    <xsd:attribute name="IsStatus" type="xsd:boolean" default="false" />
    <xsd:attribute name="StatusS" type="xsd:string" />
    <xsd:attribute name="StatusSFrom" type="datetimeSQL" />
    <xsd:attribute name="StatusSTo" type="datetimeSQL" />
    <xsd:attribute name="StatusSFromBy" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusSToBy" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusW" type="xsd:string" />
    <xsd:attribute name="StatusWFrom" type="datetimeSQL" />
    <xsd:attribute name="StatusWTo" type="datetimeSQL" />
    <xsd:attribute name="StatusWFromBy" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusWToBy" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusP" type="xsd:string" />
    <xsd:attribute name="StatusPFrom" type="datetimeSQL" />
    <xsd:attribute name="StatusPTo" type="datetimeSQL" />
    <xsd:attribute name="StatusPFromBy" type="xsd:unsignedInt" />
    <xsd:attribute name="StatusPToBy" type="xsd:unsignedInt" />
  </xsd:attributeGroup>
  <xsd:complexType name="Attribute">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:choice maxOccurs="2">
            <xsd:sequence>
              <xsd:element name="History" type="History" />
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="Statuses" type="Statuses" />
            </xsd:sequence>
          </xsd:choice>
          <xsd:choice>
            <xsd:sequence>
              <xsd:element name="ValFile" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Id" type="xsd:unsignedInt" use="required" />
                      <xsd:attribute name="Name" type="xsd:string" use="required" />
                      <xsd:attribute name="Extension" use="required">
                        <xsd:simpleType>
                          <xsd:restriction base="xsd:string">
                            <xsd:maxLength value="9" />
                          </xsd:restriction>
                        </xsd:simpleType>
                      </xsd:attribute>
                      <xsd:attribute name="Description" type="xsd:string" />
                      <xsd:attribute name="Md5" use="required">
                        <xsd:simpleType>
                          <xsd:restriction base="xsd:hexBinary">
                            <xsd:length value="16" />
                          </xsd:restriction>
                        </xsd:simpleType>
                      </xsd:attribute>
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValDictionary" type="AttributeValDictionary" minOccurs="0" maxOccurs="unbounded" />
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValTime" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Value" type="xsd:time" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValDate" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Value" type="xsd:date" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValDatetime" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Value" type="datetimeSQL" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValBit" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Value" type="xsd:boolean" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValFloat" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Value" type="xsd:float" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValInt" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Value" type="xsd:int" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValString" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Value" type="xsd:string" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValHidden" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence />
                      <xsd:attribute name="Value" type="xsd:string" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValDecimal" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Value" type="xsd:decimal" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
            <xsd:sequence>
              <xsd:element name="ValDouble" minOccurs="0" maxOccurs="unbounded">
                <xsd:complexType>
                  <xsd:complexContent>
                    <xsd:restriction base="xsd:anyType">
                      <xsd:sequence>
                        <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
                      </xsd:sequence>
                      <xsd:attribute name="Value" type="xsd:double" use="required" />
                    </xsd:restriction>
                  </xsd:complexContent>
                </xsd:complexType>
              </xsd:element>
            </xsd:sequence>
          </xsd:choice>
        </xsd:sequence>
        <xsd:attributeGroup ref="Identifications_AG" />
        <xsd:attributeGroup ref="Administratives_AG" />
        <xsd:attribute name="Priority" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="UIOrder" type="xsd:unsignedInt" use="required" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="AttributeValDictionary">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence>
          <xsd:element name="History" type="HistoryForValues_Type" minOccurs="0" />
        </xsd:sequence>
        <xsd:attribute name="Id" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="ElementId" type="xsd:unsignedInt" use="required" />
        <xsd:attribute name="DisplayValue" type="xsd:string" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="History">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attributeGroup ref="Histories_AG" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="HistoryForValues_Type">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attributeGroup ref="Attribute_Type_Histories_AG" />
        <xsd:attributeGroup ref="Statuses_AG" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="Request_BaseType">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attributeGroup ref="BaseRequest_AG" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name="Statuses">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attributeGroup ref="Statuses_AG" />
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
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
      <xsd:enumeration value="AttributeTypes_IsUsedByUnitType" />
      <xsd:enumeration value="DataTypes_Get" />
      <xsd:enumeration value="DataTypes_Delete" />
      <xsd:enumeration value="DataTypes_Save" />
      <xsd:enumeration value="DataTypes_GetHistory" />
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
      <xsd:enumeration value="Structures_DeleteElements" />
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
      <xsd:enumeration value="Roles_DeleteAssignedOperations" />
      <xsd:enumeration value="Operations_Get" />
      <xsd:enumeration value="Attributes_GetHistory" />
      <xsd:enumeration value="AttributeTypes_GetAvailable" />
      <xsd:enumeration value="Dictionary_DeleteEntries" />
      <xsd:enumeration value="AttributeTypes_GetByIds" />
      <xsd:enumeration value="AttributeTypes_DeleteAssignedBranches" />
      <xsd:enumeration value="RelationTypes_DeleteAssignedAttributeTypes" />
      <xsd:enumeration value="UnitTypes_DeleteAssignedAttributeTypes" />
      <xsd:enumeration value="Structures_GetByUnit" />
      <xsd:enumeration value="UserGroups_DeleteAssignedUsers" />
      <xsd:enumeration value="UserGroups_DeleteAssignedRoles" />
      <xsd:enumeration value="UnitsOfMeasure_DeleteAssignedConversions" />
      <xsd:enumeration value="StructureTypes_DeleteElements" />
      <xsd:enumeration value="AttributeTypes_IsUsed" />
      <xsd:enumeration value="Structures_GetByUnitType" />
      <xsd:enumeration value="UserSettings_Save" />
      <xsd:enumeration value="Relations_GetOfType" />
      <xsd:enumeration value="RelationBaseTypes_Save" />
      <xsd:enumeration value="RelationBaseTypes_Delete" />
      <xsd:enumeration value="Units_SaveAlternativeHistoryAttribute" />
      <xsd:enumeration value="Units_SetMainHistFlowForAttribute" />
      <xsd:enumeration value="Relations_SetMainHistFlowForAttribute" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="datetimeSQL">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="((000[1-9])|(00[1-9][0-9])|(0[1-9][0-9]{2})|([1-9][0-9]{3}))-((0[1-9])|(1[012]))-((0[1-9])|([12][0-9])|(3[01]))T(([01][0-9])|(2[0-3]))(:[0-5][0-9]){2}(\.[0-9]{1,3})?(Z?)" />
    </xsd:restriction>
  </xsd:simpleType>
</xsd:schema>';

