import RealmSwift

class MovieTb: Object, ITable {

    @Persisted(primaryKey: true) var Id: Int
    @Persisted var Name: String
    @Persisted var Overview: String
    @Persisted var PostUrl: String
}
