test {
    rules = {
        main = true
    }
}

mock "tfconfig/v2" {
    module {
        source = "mock-tfconfig-v2-pass.sentinel"
    }
}