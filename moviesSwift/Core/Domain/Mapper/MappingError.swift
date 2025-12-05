enum MappingError: Error
{
    case CannotConvertEntity(entity: String)
    case CannotConvertDto(dto: String)
}
