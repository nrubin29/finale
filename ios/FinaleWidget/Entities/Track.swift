struct LTrackInfoResponse : Codable {
    let track: LTrack?
}

struct LTrack : Codable {
    let name: String
    let url: String
    let listeners: String
    let mbid: String?
    let duration: String
    let playcount: String
    let artist: LTrackArtist
    let album: LTrackAlbum?
}

struct LTrackArtist : Codable {
    let name: String
    let mbid: String?
    let url: String
}

struct LTrackAlbum : Codable {
    let artist: String
    let title: String
    let mbid: String?
    let url: String
    let image: [LImage]
}
