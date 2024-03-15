class Hood
  attr_accessor :arr, :i, :j

  def initialize(arr:, i:, j:)
    @arr = arr
    @i = i 
    @j = j
  end

  def near
    jp = if j+1 == arr[0].length
           0
         else
           j + 1
         end

    ip = if i+1 == arr.length
           0
         else
           i + 1
         end

    [
      arr[i][j-1],
      arr[i][jp],
      arr[i-1][j-1],
      arr[i-1][j],
      arr[i-1][jp],
      arr[ip][j-1],
      arr[ip][j],
      arr[ip][jp],
    ]
  end
end
