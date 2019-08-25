//
//  SOChordModel.swift
//  SnapOke
//
//  Created by Modi on 2019/7/31.
//  Copyright © 2019 Modi. All rights reserved.
//

/*
import ObjectMapper

class Playways: Mappable {
    var data_title: String = ""
    var data_type: String = ""
    
    var data_path: String = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_title <- map["title"]
        data_type <- map["type"]
    }
}

class Tones: Mappable {
    var data_title: String = ""
    var data_type: String = ""
    var data_playways: [Playways]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_title <- map["title"]
        data_type <- map["type"]
        data_playways <- map["playways"]
    }
}

class SOChordModel: Mappable {
    var data_title: String = ""
    var data_imageName: String = ""
    var data_type: String = ""
    var data_tones: [Tones]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_title <- map["title"]
        data_imageName <- map["imageName"]
        data_type <- map["type"]
        data_tones <- map["tones"]
    }
    
    class func getChords() -> [SOChordModel] {
        let json = "[{\"title\":\"吉他\",\"imageName\":\"icon_guitar\",\"type\":\"Guitar\",\"tones\":[{\"title\":\"民谣吉他\",\"type\":\"FolkPop\",\"playways\":[{\"title\":\"拨弦\",\"type\":\"Plucked\"},{\"title\":\"扫弦\",\"type\":\"Strum\"}]}]},{\"title\":\"中国风\",\"imageName\":\"icon_yueqin\",\"type\":\"Chinese\",\"tones\":[{\"title\":\"古筝\",\"type\":\"Guzheng\",\"playways\":[{\"title\":\"默认\",\"type\":\"Default\"}]}]},{\"title\":\"钢琴\",\"imageName\":\"icon_piano\",\"type\":\"Piano\",\"tones\":[{\"title\":\"三角钢琴\",\"type\":\"Grand\",\"playways\":[{\"title\":\"柱式\",\"type\":\"Column\"},{\"title\":\"分解和弦\",\"type\":\"Decomposition\"}]}]},{\"title\":\"合成器\",\"imageName\":\"icon_syn\",\"type\":\"Synthesizer\",\"tones\":[{\"title\":\"口技\",\"type\":\"B-Box\",\"playways\":[{\"title\":\"默认\",\"type\":\"Default\"}]}]},{\"title\":\"尤克里里\",\"imageName\":\"icon_ukulele\",\"type\":\"Ukelele\",\"tones\":[{\"title\":\"原声\",\"type\":\"Original\",\"playways\":[{\"title\":\"扫弦\",\"type\":\"Strum\"}]}]}]"
        let models: [SOChordModel] = Mapper<SOChordModel>().mapArray(JSONString: json)!
        // 给path赋值
        models.forEach { (chord) in
            chord.data_tones?.forEach({ (tone) in
                tone.data_playways?.forEach({ (playway) in
                    let path = chord.data_type + "_" + tone.data_type + "_" + playway.data_type
                    playway.data_path = path
                })
            })
        }
        return models
    }
}
*/

import ObjectMapper

class Playways: BaseModel {
    var data_categoryJp: String?
    var data_categoryEn: String?
    var data_categoryCn: String?
    var data_resource: String?
    var data_id: Int = 0
    
    //    required init?(map: Map) {}
    override init() {
        super.init()
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.data_categoryJp, forKey: "categoryJp")
        aCoder.encode(self.data_categoryEn, forKey: "categoryEn")
        aCoder.encode(self.data_categoryCn, forKey: "categoryCn")
        aCoder.encode(self.data_id, forKey: "id")
        aCoder.encode(self.data_resource, forKey: "resource")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        self.data_categoryJp = aDecoder.decodeObject(forKey: "categoryJp") as? String
        self.data_categoryEn = aDecoder.decodeObject(forKey: "categoryEn") as? String
        self.data_categoryCn = aDecoder.decodeObject(forKey: "categoryCn") as? String
        self.data_resource = aDecoder.decodeObject(forKey: "resource") as? String
        self.data_id = aDecoder.decodeInteger(forKey: "id")
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        data_categoryJp <- map["categoryJp"]
        data_categoryEn <- map["categoryEn"]
        data_categoryCn <- map["categoryCn"]
        data_categoryJp <- map["typeJp"]
        data_categoryEn <- map["typeEn"]
        data_categoryCn <- map["typeCn"]
        data_resource <- map["resource"]
        data_id <- map["id"]
    }
}

class Tones: Mappable {
    var data_classCn: String?
    var data_classEn: String?
    var data_playStyles: [Playways]?
    var data_classJp: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_classCn <- map["classCn"]
        data_classEn <- map["classEn"]
        data_playStyles <- map["playStyles"]
        data_classJp <- map["classJp"]
    }
}

class SOChordModel: Mappable {
    var data_categoryEn: String?
    var data_timbre: [Tones]?
    var data_categoryJp: String?
    var data_categoryCn: String?
    
    var data_imageName: String = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        data_categoryEn <- map["categoryEn"]
        data_timbre <- map["timbre"]
        data_categoryJp <- map["categoryJp"]
        data_categoryCn <- map["categoryCn"]
    }
    
    class func getChords() -> [SOChordModel] {
        let json = "[{\"categoryEn\":\"Chinese\",\"categoryCn\":\"中国风\",\"categoryJp\":\"中国風\",\"timbre\":[{\"classEn\":\"Guzheng\",\"classCn\":\"古筝\",\"classJp\":\"琴\",\"playStyles\":[{\"id\":1,\"typeEn\":\"Default\",\"typeCn\":\"默认\",\"typeJp\":\"黙認\",\"resource\":\"Chinese_Guzheng_Default.zip\"}]}]},{\"categoryEn\":\"Guitar\",\"categoryCn\":\"吉他\",\"categoryJp\":\"ギター\",\"timbre\":[{\"classEn\":\"Folk Pop\",\"classCn\":\"民谣吉他\",\"classJp\":\"フォークギター\",\"playStyles\":[{\"id\":3,\"typeEn\":\"Plucked\",\"typeCn\":\"拨弦\",\"typeJp\":\"ピチカート\",\"resource\":\"Guitar_Folk_Plucked.zip\"},{\"id\":4,\"typeEn\":\"Strum\",\"typeCn\":\"扫弦\",\"typeJp\":\"扫弦\",\"resource\":\"Guitar_Folk_Strum.zip\"}]}]},{\"categoryEn\":\"Piano\",\"categoryCn\":\"钢琴\",\"categoryJp\":\"ピアノ\",\"timbre\":[{\"classEn\":\"Grand\",\"classCn\":\"三角钢琴\",\"classJp\":\"グランドピアノ\",\"playStyles\":[{\"id\":7,\"typeEn\":\"Column\",\"typeCn\":\"柱式\",\"typeJp\":\"柱式\",\"resource\":\"Piano_Grand_Column.zip\"},{\"id\":8,\"typeEn\":\"Decomposition\",\"typeCn\":\"分解和弦\",\"typeJp\":\"ハーモニーを分解する\",\"resource\":\"Piano_Grand_Decom.zip\"}]}]},{\"categoryEn\":\"Synthesizer\",\"categoryCn\":\"合成器\",\"categoryJp\":\"シンセサイザー\",\"timbre\":[{\"classEn\":\"B-Box\",\"classCn\":\"口技\",\"classJp\":\"ビートボックス\",\"playStyles\":[{\"id\":10,\"typeEn\":\"Default\",\"typeCn\":\"默认\",\"typeJp\":\"黙認\",\"resource\":\"Synthesizer_BBox.zip\"}]}]},{\"categoryEn\":\"Ukelele\",\"categoryCn\":\"尤克里里\",\"categoryJp\":\"ウクレリ\",\"timbre\":[{\"classEn\":\"Original\",\"classCn\":\"原声\",\"classJp\":\"オリジナル\",\"playStyles\":[{\"id\":21,\"typeEn\":\"Strum\",\"typeCn\":\"扫弦\",\"typeJp\":\"扫弦\",\"resource\":\"Ukelele_Original_Strum.zip\"}]}]}]"
        let models: [SOChordModel] = Mapper<SOChordModel>().mapArray(JSONString: json)!
        // 给path赋值
        models.forEach { (chord) in
            let title = chord.data_categoryEn ?? ""
            switch title {
            case "Chinese":
                chord.data_imageName = "icon_yueqin"
                break
            case "Guitar":
                chord.data_imageName = "icon_guitar"
                break
            case "Piano":
                chord.data_imageName = "icon_piano"
                break
            case "Synthesizer":
                chord.data_imageName = "icon_syn"
                break
            case "Ukelele":
                chord.data_imageName = "icon_ukulele"
                break
            default:
                break
            }
        }
        return models
    }
    
    class func getPathByID(id: Int) -> String? {
        var path: String! = nil
        getChords().forEach { (chord) in
            chord.data_timbre?.forEach({ (tone) in
                tone.data_playStyles?.forEach({ (playway) in
                    if id == playway.data_id {
                        path = playway.data_resource?.replacingOccurrences(of: ".zip", with: "")
                    }
                })
            })
        }
        return path
    }
    
}
