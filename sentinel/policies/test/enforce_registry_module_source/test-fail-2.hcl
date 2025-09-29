test {
    rules = {
        main = false
    }
}

mock "tfconfig/v2" {
    module {
        source = "mock-tfconfig-v2-fail-2.sentinel"
    }
}