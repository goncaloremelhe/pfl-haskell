import qualified Data.List
import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]

type NewRoadMap = Data.Array.Array (Int, Int) (Maybe Distance)

type CityIndex = [(City, Int)]


getIntFromMaybe :: Maybe Int -> Int
getIntFromMaybe (Just x) = x
getIntFromMaybe Nothing = maxBound


-- Index in list of (City, index of city). Ex: [(City1, 0), (City2, 1), (City3, 2)]
toCityIndex :: RoadMap -> CityIndex
toCityIndex idx = zip (Data.List.nub ( concat ( [ [x,y] | (x, y, _ ) <- idx]) )) [0..]

-- Using the cityIndex and a city, get its index
getIndex :: CityIndex -> City -> Int
getIndex map city = case lookup city map of
    Just idx -> idx
    Nothing -> error "City not found"

-- First creates an Array filled with nothing, then for each entry on RoadMap, it updates the array with the Distance
roadArray :: RoadMap -> NewRoadMap
roadArray map = foldl updateArray initialArray map
    where
        cityIdx = toCityIndex map
        len = length cityIdx
        initialArray = Data.Array.array ((0,0), (len, len)) [((i,j), Nothing) | i <- [0..len-1], j <- [0..len-1]]
        updateArray arr (c1, c2, dist) =
            let i = getIndex cityIdx c1
                j = getIndex cityIdx c2
            in arr Data.Array.// [((i, j), Just dist), ((j, i), Just dist)]



cities :: RoadMap -> [City] --Prints a list of all the cities, duplicates are removed using nub
cities r = [ x | (x, _) <- toCityIndex r]



areAdjacent :: RoadMap -> City -> City -> Bool --Returns True if two cities have an edge connecting them, False otherwise. (c1,c2,d) -> each tuple in the roadmap; ci1 and ci2 -> given cities
areAdjacent [] _ _ = False
areAdjacent ((c1,c2,d):t) ci1 ci2
    | ci1==c1 && ci2==c2 = True
    | ci1==c2 && ci2==c1 = True
    | otherwise = areAdjacent t ci1 ci2



distance :: RoadMap -> City -> City -> Maybe Distance  --Returns Just distance between two cities if there is an edge connecting them and Nothing otherwise. (c1,c2,d) -> each tuple in the roadmap; ci1 and ci2 -> given cities
distance [] _ _ = Nothing
distance ((c1,c2,d):t) ci1 ci2
    | ci1==c1 && ci2==c2 = Just d
    | ci1==c2 && ci2==c1 = Just d
    | otherwise = distance t ci1 ci2



adjacent :: RoadMap -> City -> [(City,Distance)] --Returns a list of tuples with every city adjacent to a given city and the distance between them. (c1,c2,d) -> each tuple in the roadmap; ci1 -> given city
adjacent [] _ = []
adjacent ((c1,c2,d):t) ci1
    | ci1 == c1 = (c2,d) : adjacent t ci1
    | ci1 == c2 = (c1,d) : adjacent t ci1
    | otherwise = adjacent t ci1



pathDistance :: RoadMap -> Path -> Maybe Distance --Returns the distance between all the cities in a path if they are consecutive. (ci1:ci2:r) <- ci1 is the current city in the path, ci2 is the nxt city, r is the tail of the path
pathDistance _ [] = Just 0
pathDistance _ [_] = Just 0
pathDistance roadMap (ci1:ci2:r)= do
    d <- distance roadMap ci1 ci2
    rest <- pathDistance roadMap (ci2:r)
    return (d + rest)



------------------------- Rome and auxiliar function -------------------------
-- Takes list of unique cities and takes the length of the adjacent vertices of each vertice and creates a list with the format ( City, Number of adjacent vertices )
verticeDegrees :: RoadMap -> [(City, Int)]
verticeDegrees roadMap =
    let
        uniqueCities = cities roadMap
        degree v = length (adjacent roadMap v)
    in [(v, degree v) | v <- uniqueCities]

-- Takes list of vertice degrees built in auxiliary function, calculates the maximum degree and outputs the cities with that degree
rome :: RoadMap -> [City]
rome roadMap =
    let
        degreeslist = verticeDegrees roadMap
        maxDegree = maximum[degree | (city,degree)<-degreeslist]
    in [city | (city,degree)<-degreeslist, degree ==  maxDegree]
----------------------------------------------------------------------




------------- isStronglyConnected and auxiliar function --------------
dfs :: RoadMap -> [City] -> [City] -> [City]                            --depth first search 
dfs _ visited [] = reverse visited
dfs roadMap visited (x:xs)
    | elem x visited = dfs roadMap visited xs                           -- if x was already visited, dont add it do the visited list, continue searching
    | otherwise      = dfs roadMap (x:visited) (adjacentCities ++ xs)   --x wasnt visited, so we add it to the visited list and continue
    where adjacentCities = [c1 | (c1, _) <- adjacent roadMap x]

isStronglyConnected :: RoadMap -> Bool
isStronglyConnected roadMap =
    let
    allCities = cities roadMap
    dfsing = dfs roadMap [] [head allCities]
    in length dfsing == length allCities                                -- the number of visited cities must be equal to the total number of cities
----------------------------------------------------------------------




---------------- shortestPath and auxiliar functions -----------------

-- Dijkstra's algorithm to find the shortest distance between 2 cities
dijkstra :: RoadMap -> City -> City -> Maybe Distance
dijkstra r c1 c2 = 
    let
        -- convert the road map to a distance array and get city indices
        nr = roadArray r
        cityIdx = toCityIndex r
        len = length cityIdx
        
        -- get the index of the starting and target cities
        c1_idx = getIndex cityIdx c1
        c2_idx = getIndex cityIdx c2
        
        -- initialize the distance array with max bounds, except the start city
        distanceArray = Data.Array.array (0, len-1) [ (i, if i == c1_idx then 0 else maxBound) | i <- [0..len-1]]
        
        -- initialize visited array to keep track of visited cities
        visited = Data.Array.array (0, len-1) [(i, False) | i <- [0..len-1]]
    
        -- auxiliar recursive function for Dijkstra's algorithm
        dijkstra' :: Data.Array.Array Int Distance -> Data.Array.Array Int Bool -> [(Int, Distance)] -> Distance
        dijkstra' distanceArray visited [] = distanceArray Data.Array.! c2_idx  -- Return distance to target city
        dijkstra' distanceArray visited queue =
            let
                -- find the city with the smallest distance in the queue
                (u, distU) = Data.List.minimumBy (\(_, d1) (_, d2) -> compare d1 d2) queue
                
                -- remove this city from the queue
                queue' = Data.List.delete (u, distU) queue
                
                -- mark the city as visited
                visited' = visited Data.Array.// [(u, True)]
                
                -- find unvisited neighbors of the current city
                neighbors = [v | v <- [0..len-1], not (visited' Data.Array.! v), (nr Data.Array.! (u, v)) /= Nothing]

                -- update distances to the neighbors
                newDistances = foldl
                    (\d v -> let alt = distU + (case nr Data.Array.! (u, v) of Just d -> d; Nothing -> maxBound)
                             in if alt < d Data.Array.! v then d Data.Array.// [(v, alt)] else d)
                    distanceArray
                    neighbors

                -- update the queue
                newQueue = foldl
                    (\q v -> let alt = distU + (case nr Data.Array.! (u, v) of Just d -> d; Nothing -> maxBound)
                             in if alt < distanceArray Data.Array.! v
                                then (v, alt) : q
                                else q)
                    queue'
                    neighbors
            in dijkstra' newDistances visited' newQueue  -- Recursive call with updated distance and visited arrays
    
    in 
        let result = dijkstra' distanceArray visited [(c1_idx, 0)]
        in if result == maxBound then Nothing else Just result  -- Nothing if the target is unreachable

-- Another approach for the adjacent function. This one differs by using the NewRoadMap array type instead of the RoadMap type
adjacentArray :: NewRoadMap -> CityIndex -> Int -> [(Int, Distance)]
adjacentArray adjMatrix cityIdx cityIdxNum = 
    [(v, getIntFromMaybe d) | v <- [0..len-1], let d = adjMatrix Data.Array.! (cityIdxNum, v), d /= Nothing, let Just d' = d]
    where len = length cityIdx

-- DFS to find all possible shortest paths between 2 cities
dfsAllShortestPaths :: NewRoadMap -> CityIndex -> Int -> Int -> Distance -> Path -> Distance -> [Path] -> [Path]
dfsAllShortestPaths arrayMap cityIdx currCity c2 minDist currPath currDist allPaths
    | currCity == c2 && currDist == minDist = (currPath ++ [fst (cityIdx !! c2)]):allPaths  -- found a valid path -> Added to allPaths
    | currDist > minDist = allPaths  -- exceeded the minimum distance -> discard this path
    | otherwise = 
        foldl 
            -- keeps searching for new paths
            (\acc (nextCity, dist) -> dfsAllShortestPaths arrayMap cityIdx nextCity c2 minDist (currPath ++ [fst (cityIdx !! currCity)]) (currDist + dist) acc) 
            allPaths 
            (adjacentArray arrayMap cityIdx currCity)

-- Shortest path function using DFS and Dijkstra
shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath r c1 c2 =
    case dijkstra r c1 c2 of
        Nothing -> []  -- no path found
        Just minDist -> dfsAllShortestPaths arrayMap cityIdx c1_idx c2_idx minDist [] 0 []          -- find all paths with the shortest distance
    where
        arrayMap = roadArray r                     
        cityIdx = toCityIndex r                    
        c1_idx = getIndex cityIdx c1                
        c2_idx = getIndex cityIdx c2                
----------------------------------------------------------------------



---------------- travelSales and auxiliar functions ------------------

-- solve the TSP using dynamic programming and bit masking
tsp :: NewRoadMap -> Int -> Int -> Int -> Data.Array.Array (Int, Int) (Maybe Int, [Int]) -> (Maybe Int, [Int])
tsp roadMap n mask pos dynamicTable
    -- base case: all cities have been visited, return to the start city
    | mask == (Data.Bits.shiftL 1 n) - 1 = (roadMap Data.Array.! (pos, 0), [pos])
    | otherwise =
        -- check if the result is already computed and stored in the dynamic table
        case dynamicTable Data.Array.! (pos, mask) of

            -- if the result is already computed, return it
            (Just _, _) -> dynamicTable Data.Array.! (pos, mask)

            -- if the result is not computed, calculate it
            (Nothing, _) ->
                let 
                    -- generate all possible results by visiting the next unvisited city
                    results = [ (distance, pos : path) | next <- [0 .. n - 1],
                                mask Data.Bits..&. Data.Bits.shiftL 1 next == 0,        -- check if the next city is unvisited
                                -- Recursively solve the subproblem with the next city visited
                                let (dist, path) = tsp roadMap n (mask Data.Bits..|. Data.Bits.shiftL 1 next) next dynamicTable,
                                -- Calculate the total distance
                                let distance = (+) <$> (roadMap Data.Array.! (pos, next)) <*> dist,
                                distance /= Nothing]
                    -- find the result with the minimum distance
                    bestResult = if null results
                                 then (Nothing, [])
                                 else Data.List.minimumBy compareResult results
                -- store the result in the dynamic table
                in dynamicTable Data.Array.// [((pos, mask), bestResult)] Data.Array.! (pos, mask)
  where
    -- comparison function to find the minimum distance
    compareResult (Nothing, _) (Nothing, _) = EQ
    compareResult (Nothing, _) _ = GT
    compareResult _ (Nothing, _) = LT
    compareResult (Just c1, _) (Just c2, _) = compare c1 c2

-- Main function to solve TSP
travelSales :: RoadMap -> Path
travelSales r =
    let 
        cityIdx = toCityIndex r
        roadMap = roadArray r
        n = length cityIdx 

        -- Table for dynamic programming 
        dynamicTable = Data.Array.array ((0,0), (n-1, (Data.Bits.shiftL 1 n) - 1)) [((i, s), (Nothing, [])) | i <- [0..n-1], s <- [0..(Data.Bits.shiftL 1 n) - 1]]

        result = tsp roadMap n 1 0 dynamicTable                         -- solve TSP from starting position
    in case result of
        (Nothing, _) -> []                                              -- no valid path found
        (Just _, path) -> map (\i -> fst (cityIdx !! i)) (path ++ [0])  -- add start city to the end to complete the cycle -> map indexes (Int) to City (String)

---------------------------------------------------------------------


tspBruteForce :: RoadMap -> Path
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function

-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)]

gTest4 :: RoadMap
gTest4 = [
    ("0", "1", 10), ("0", "2", 15), ("1", "3", 5), ("2", "4", 10), ("3", "5", 2),
    ("4", "6", 8), ("5", "7", 12), ("6", "8", 4), ("7", "9", 7), ("8", "10", 9),
    ("9", "11", 14), ("10", "12", 6), ("11", "13", 5), ("12", "14", 15),
    ("13", "15", 8), ("14", "16", 11), ("15", "17", 3), ("16", "18", 7),
    ("17", "19", 20), ("0", "5", 9), ("1", "6", 14), ("2", "7", 12),
    ("3", "8", 7), ("4", "9", 6), ("5", "10", 13), ("6", "11", 10),
    ("7", "12", 18), ("8", "13", 9), ("9", "14", 4), ("10", "15", 7),
    ("11", "16", 12), ("12", "17", 15), ("13", "18", 2), ("14", "19", 5),
    ("0", "10", 3), ("1", "11", 16), ("2", "12", 8), ("3", "13", 10),
    ("4", "14", 13), ("5", "15", 9), ("6", "16", 11), ("7", "17", 6),
    ("8", "18", 14), ("9", "19", 4)]