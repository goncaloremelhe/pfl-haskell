import qualified Data.List
--import qualified Data.Array
--import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]

cities :: RoadMap -> [City] --Prints a list of all the cities, duplicates are removed using nub
cities r = Data.List.nub ( concat ( [ [x,y] | (x, y, _ ) <- r]) )

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

---------------------------aux function for rome
--takes list of unique cities and takes the length of the adjacent vertices of each vertice and creates a list with the format (city,number of adjacent vertices)

verticeDegrees :: RoadMap -> [(City, Int)]
verticeDegrees roadMap =
    let
    uniqueCities = cities roadMap
    degree v = length (adjacent roadMap v)
    in [(v, degree v) | v <- uniqueCities]
---------------------------------------------

rome :: RoadMap -> [City] --takes list of vertice degrees built in auxiliary function, calculates the maximum degree and outputs the cities with that degree
rome roadMap =
    let
    degreeslist = verticeDegrees roadMap
    maxDegree = maximum[degree | (city,degree)<-degreeslist]
    in[city | (city,degree)<-degreeslist, degree ==  maxDegree]

------------------------------aux function for isStronglyConnected
dfs :: RoadMap -> [City] -> [City] -> [City] --depth first search 
dfs _ visited [] = reverse visited
dfs roadMap visited (x:xs)
    | elem x visited = dfs roadMap visited xs -- if x was already visited, dont add it do the visited list, continue searching
    | otherwise      = dfs roadMap (x:visited) (adjacentCities ++ xs) --x wasnt visited, so we add it to the visited list and continue
    where adjacentCities = [c1 | (c1, _) <- adjacent roadMap x]
---------------------------------------------

isStronglyConnected :: RoadMap -> Bool
isStronglyConnected roadMap =
    let
    allCities = cities roadMap
    dfsing = dfs roadMap [] [(head allCities)]
    in length dfsing == length allCities

--Dijkstra
shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath = undefined

travelSales :: RoadMap -> Path
travelSales = undefined

tspBruteForce :: RoadMap -> Path
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function

-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)]




-- Versão flop
cities' :: RoadMap -> [City]
cities' r = Data.List.nub ( concat ( [ [x,y] | (x, y, _ ) <- r]) )

areAdjacent' :: RoadMap -> City -> City -> Bool
areAdjacent' [] _ _ = False
areAdjacent' ((a,b,c):r1) c1 c2 = (a == c1 && b == c2) || (a == c2 && b == c1) || areAdjacent' r1 c1 c2

distance' :: RoadMap -> City -> City -> Maybe Distance
distance' [] _ _ = Nothing
distance' ((a,b,c):r1) c1 c2
    | a == c1 && b == c2 = Just c
    | a == c2 && b == c1 = Just c
    | otherwise = distance' r1 c1 c2
    

adjacent' :: RoadMap -> City -> [(City,Distance)]
adjacent' [] _ = []
adjacent' ((a,b,c):r1) c1
    | c1 == a = (b,c): adjacent' r1 c1
    | c1 == b = (a,c): adjacent' r1 c1
    | otherwise = adjacent' r1 c1