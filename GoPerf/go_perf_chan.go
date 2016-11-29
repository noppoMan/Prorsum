package main

func main() {
    count := 1000000
    ch := make(chan int, 1)
    for i := 0; i < count; i++ {
      go func(i int){
        ch <- i
      }(i)
    }

    for i := 0; i < count; i++ {
        select {
        case i := <-ch:
          if i == count-1 {
            break
          }
        }
    }
}
