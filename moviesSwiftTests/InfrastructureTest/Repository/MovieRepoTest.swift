import XCTest
@testable import moviesSwift

final class MovieRepoTest: RepoDi
{    
    static var newId: Int = 1

    // MARK: - T1_1 Add Movie Test
    func test_T1_1AddMovieTest() async throws
    {        
        let movieRepo: any IRepository<Movie> = ContainerLocator.Resolve()

        let movieEntity = Movie.Create(
            "test movie from unittest",
            "good movie",
            "no url"
        )

        try await movieRepo.AddAsync(movieEntity)
        XCTAssertTrue(movieEntity.Id > 0, "new movieEntity id doesn't increment")
        // save for next test
        MovieRepoTest.newId = movieEntity.Id
    }

    // MARK: - T1_2 Add All Movies
    func test_T1_2AddAllMovieTest() async throws
    {
        let movieRepo: any IRepository<Movie> = ContainerLocator.Resolve()

        let movie1 = Movie.Create(
            "test movie from unittest",
            "good movie",
            "no url"
        )

        let movie2 = Movie.Create(
            "test movie from unittest2",
            "good movie2",
            "no url2"
        )

        try await movieRepo.AddAllAsync([movie1, movie2])

        XCTAssertTrue(movie1.Id > 0, "new first id doesn't increment")
        XCTAssertTrue(movie2.Id > 0, "new second movie id doesn't increment")
    }

    // MARK: - T1_3 Get List Test
    func test_T1_3GetListTest() async throws
    {
        let movieRepo: any IRepository<Movie> = ContainerLocator.Resolve()

        let list = try await movieRepo.GetListAsync()

        XCTAssertTrue(list.count > 0, "Movie list should not be empty")
    }

    // MARK: - T1_4 Get Movie Test
    func test_T1_4GetMovieTest() async throws
    {
        let movieRepo: any IRepository<Movie> = ContainerLocator.Resolve()

        let id = MovieRepoTest.newId
        let entity = try await movieRepo.FindById(id)

        XCTAssertNotNil(entity, "FindById() returned nil")
        XCTAssertTrue(entity!.Id > 0, "entity has incorrect id")
    }

    // MARK: - T1_5 Update Movie Test
    func test_T1_5UpdateMovieTest() async throws
    {
        let movieRepo: any IRepository<Movie> = ContainerLocator.Resolve()

        let id = MovieRepoTest.newId
        guard let entity = try await movieRepo.FindById(id) else
        {
            XCTFail("Can not find movie entity")
            return
        }

        entity.Name = "updated name"
        let success = try await movieRepo.UpdateAsync(entity)
        XCTAssertTrue(success > 0, "UpdateAsync() returned 0 rows updated")
    }

    // MARK: - T1_6 Delete Movie Test
    func test_T1_6DeleteMovieTest() async throws
    {
        let movieRepo: any IRepository<Movie> = ContainerLocator.Resolve()

        var entity = try await movieRepo.FindById(1)
        XCTAssertNotNil(entity, "Can not find entity with id=1")

        let deleted = try await movieRepo.RemoveAsync(entity!)
        XCTAssertTrue(deleted > 0, "DeleteAsync returned zero deleted rows")

        entity = try await movieRepo.FindById(1)
        XCTAssertNil(entity, "Entity was not removed")
    }

    // MARK: - T1_7 Clear All Test
    func test_T1_7ClearAllMovieTest() async throws
    {
        let movieRepo: any IRepository<Movie> = ContainerLocator.Resolve()

        _ = try await movieRepo.ClearAsync(reason: "test clear")

        let list = try await movieRepo.GetListAsync()
        XCTAssertEqual(list.count, 0, "table still has data after clear()")
    }
    
//    func EnsureDbInited() async throws
//    {
//        let dbInitilizer: ILocalDbInitilizer = ContainerLocator.Resolve()
//        try! await dbInitilizer.InitDb()
//    }
}

