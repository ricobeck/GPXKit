import Foundation

public struct Coordinate: Equatable {
    public let latitude: Double
    public let longitude: Double
    public let elevation: Double
}

public struct TrackSegment: Equatable {
    public let coordinate: Coordinate
    public let distanceInMeters: Double
}

public struct TrackPoint: Equatable {
	public let coordinate: Coordinate
	public let date: Date
	public let power: Measurement<UnitPower>?

	public init(coordinate: Coordinate, date: Date, power: Measurement<UnitPower>? = nil) {
		self.coordinate = coordinate
		self.date = date
		self.power = power
	}
}

public struct TrackGraph: Equatable {
    public let segments: [TrackSegment]
    public let distance: Double
    public let elevationGain: Double
}