//
//  API.swift
//  DevTemplate
//
//  Created by Raistlin on 2017/12/13.
//  Copyright © 2017年 jimlai. All rights reserved.
//

import Siesta

class API: Service {
    var search: Resource {return resource("/search/repositories")}
    var test: Resource {return resource("/test")}
    var authToken: String? {
        didSet {
            // Rerun existing configuration closure using new value
            invalidateConfiguration()
            
            // Wipe any cached state if auth token changes
            wipeResources()
        }
    }
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = false
        super.init(
            baseURL: "https://api.github.com",
            networking: AlamofireProvider(configuration: configuration)
        )
        configure {
            $0.headers["Authorization"] = "3afccf613d075e5a652f96a367f81262d657bdf4"
            $0.headers["User-Agent"] = "jimlai586"
            $0.pipeline[.parsing].add(
                SwiftyJSONTransformer,
                contentTypes: ["*/json"])
        }
    }
    
}
