import XCTest
@testable import GPXKit

class TrackGraphTests: XCTestCase {
    var sut: TrackGraph!
    let coordinates: [Coordinate] = [
        Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 82.2),
        Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 82.2),
        Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 82.2),
        Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 82.2),
        Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 82.2),
    ]

    override func setUp() {
        super.setUp()
        sut = TrackGraph(coords: coordinates)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private func givenAPoint(latitude: Double, longitude: Double, elevation: Double) -> TrackPoint {
		return TrackPoint(coordinate: Coordinate(latitude: latitude, longitude: longitude, elevation: elevation), date: Date())
    }

    private func expectedDistance(from: Coordinate, to: Coordinate) -> Double {
        return from.distance(to: to)
    }

    // MARK: Tests

    func testSegmentDistances() {
        let expectedDistances = [0.0] + zip(coordinates, coordinates.dropFirst()).map {
            expectedDistance(from: $0, to: $1)
        }

        for (index, expectedDistance) in expectedDistances.enumerated() {
            XCTAssertEqual(sut.segments[index].distanceInMeters, expectedDistance, accuracy: 0.001)
        }
    }

    func testTotalDistance() {
        let totalDistance = zip(coordinates, coordinates.dropFirst()).map {
            expectedDistance(from: $0, to: $1)
        }.reduce(0, +)

        XCTAssertEqual(totalDistance, sut.distance, accuracy: 0.01)
    }

    func testTotalElevationWithTheSameElevationAtEveryPoint() {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 1),
        ]

        sut = TrackGraph(coords: coordinates)

        XCTAssertEqual(0, sut.elevationGain)
    }

    func testTotalElevationWithDifferentElevation() {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 11), // 10
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 5), // -6
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 100), // 95
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 76), // -24
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 344), // 268
        ]

        sut = TrackGraph(coords: coordinates)

        // 10 + 95 + 268
        XCTAssertEqual(373, sut.elevationGain)
    }

    func testInitializationFromGPX() {
        let points: [TrackPoint] = [
            givenAPoint(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            givenAPoint(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            givenAPoint(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            givenAPoint(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            givenAPoint(latitude: 51.2765020, longitude: 12.3767050, elevation: 1),
        ]

        sut = TrackGraph(points: points)

        let expectedCoordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 1),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 1),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 1),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 1),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 1),
        ]
        XCTAssertEqual(expectedCoordinates, sut.segments.map { $0.coordinate })
    }

    func testTheInitialElevationIsSubstractedFromTheElevationGain() {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 100),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 110),
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 120),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 130),
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 140),
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 150),
        ]

        sut = TrackGraph(coords: coordinates)

        // 10 + 95 + 268
        XCTAssertEqual(50, sut.elevationGain)
    }

    func testElevationGainIsTheSumOfAllElevationDifferences() {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 51.2763320, longitude: 12.3767670, elevation: 100),
            Coordinate(latitude: 51.2763700, longitude: 12.3767550, elevation: 130), // 30
            Coordinate(latitude: 51.2764100, longitude: 12.3767400, elevation: 70),
            Coordinate(latitude: 51.2764520, longitude: 12.3767260, elevation: 150), // 80
            Coordinate(latitude: 51.2765020, longitude: 12.3767050, elevation: 140),
            Coordinate(latitude: 51.2765520, longitude: 12.3766820, elevation: 150), // 10
        ]

        sut = TrackGraph(coords: coordinates)

        XCTAssertEqual(30 + 80 + 10, sut.elevationGain)
    }
}


