import SwiftUI

struct Cloud: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.69744*width, y: 0.73938*height))
        path.addCurve(to: CGPoint(x: 0.72158*width, y: 0.73537*height), control1: CGPoint(x: 0.70606*width, y: 0.73938*height), control2: CGPoint(x: 0.71411*width, y: 0.73804*height))
        path.addCurve(to: CGPoint(x: 0.7412*width, y: 0.72428*height), control1: CGPoint(x: 0.72905*width, y: 0.7327*height), control2: CGPoint(x: 0.73559*width, y: 0.729*height))
        path.addCurve(to: CGPoint(x: 0.7543*width, y: 0.70782*height), control1: CGPoint(x: 0.7468*width, y: 0.71955*height), control2: CGPoint(x: 0.75117*width, y: 0.71407*height))
        path.addCurve(to: CGPoint(x: 0.75899*width, y: 0.68771*height), control1: CGPoint(x: 0.75742*width, y: 0.70157*height), control2: CGPoint(x: 0.75899*width, y: 0.69487*height))
        path.addCurve(to: CGPoint(x: 0.75464*width, y: 0.66714*height), control1: CGPoint(x: 0.75899*width, y: 0.68042*height), control2: CGPoint(x: 0.75754*width, y: 0.67356*height))
        path.addCurve(to: CGPoint(x: 0.74217*width, y: 0.65006*height), control1: CGPoint(x: 0.75174*width, y: 0.66072*height), control2: CGPoint(x: 0.74759*width, y: 0.65502*height))
        path.addCurve(to: CGPoint(x: 0.72284*width, y: 0.63834*height), control1: CGPoint(x: 0.73676*width, y: 0.64509*height), control2: CGPoint(x: 0.73031*width, y: 0.64119*height))
        path.addCurve(to: CGPoint(x: 0.71655*width, y: 0.60631*height), control1: CGPoint(x: 0.72284*width, y: 0.62674*height), control2: CGPoint(x: 0.72074*width, y: 0.61606*height))
        path.addCurve(to: CGPoint(x: 0.69887*width, y: 0.58089*height), control1: CGPoint(x: 0.71235*width, y: 0.59655*height), control2: CGPoint(x: 0.70646*width, y: 0.58808*height))
        path.addCurve(to: CGPoint(x: 0.67233*width, y: 0.56422*height), control1: CGPoint(x: 0.69129*width, y: 0.5737*height), control2: CGPoint(x: 0.68244*width, y: 0.56815*height))
        path.addCurve(to: CGPoint(x: 0.63956*width, y: 0.55834*height), control1: CGPoint(x: 0.66223*width, y: 0.5603*height), control2: CGPoint(x: 0.65131*width, y: 0.55834*height))
        path.addCurve(to: CGPoint(x: 0.61148*width, y: 0.56287*height), control1: CGPoint(x: 0.62919*width, y: 0.55834*height), control2: CGPoint(x: 0.61983*width, y: 0.55985*height))
        path.addCurve(to: CGPoint(x: 0.58929*width, y: 0.57495*height), control1: CGPoint(x: 0.60313*width, y: 0.56589*height), control2: CGPoint(x: 0.59573*width, y: 0.56992*height))
        path.addCurve(to: CGPoint(x: 0.57276*width, y: 0.59167*height), control1: CGPoint(x: 0.58284*width, y: 0.57999*height), control2: CGPoint(x: 0.57733*width, y: 0.58556*height))
        path.addCurve(to: CGPoint(x: 0.55177*width, y: 0.59079*height), control1: CGPoint(x: 0.56574*width, y: 0.5898*height), control2: CGPoint(x: 0.55874*width, y: 0.5895*height))
        path.addCurve(to: CGPoint(x: 0.53272*width, y: 0.5985*height), control1: CGPoint(x: 0.54479*width, y: 0.59207*height), control2: CGPoint(x: 0.53844*width, y: 0.59464*height))
        path.addCurve(to: CGPoint(x: 0.51888*width, y: 0.61308*height), control1: CGPoint(x: 0.527*width, y: 0.60235*height), control2: CGPoint(x: 0.52239*width, y: 0.60721*height))
        path.addCurve(to: CGPoint(x: 0.51339*width, y: 0.63282*height), control1: CGPoint(x: 0.51537*width, y: 0.61895*height), control2: CGPoint(x: 0.51354*width, y: 0.62553*height))
        path.addCurve(to: CGPoint(x: 0.49102*width, y: 0.64178*height), control1: CGPoint(x: 0.50477*width, y: 0.63407*height), control2: CGPoint(x: 0.49732*width, y: 0.63705*height))
        path.addCurve(to: CGPoint(x: 0.4765*width, y: 0.65959*height), control1: CGPoint(x: 0.48473*width, y: 0.6465*height), control2: CGPoint(x: 0.47989*width, y: 0.65244*height))
        path.addCurve(to: CGPoint(x: 0.47141*width, y: 0.68303*height), control1: CGPoint(x: 0.4731*width, y: 0.66674*height), control2: CGPoint(x: 0.47141*width, y: 0.67455*height))
        path.addCurve(to: CGPoint(x: 0.47655*width, y: 0.70469*height), control1: CGPoint(x: 0.47141*width, y: 0.69066*height), control2: CGPoint(x: 0.47312*width, y: 0.69789*height))
        path.addCurve(to: CGPoint(x: 0.49102*width, y: 0.72266*height), control1: CGPoint(x: 0.47998*width, y: 0.7115*height), control2: CGPoint(x: 0.48481*width, y: 0.71749*height))
        path.addCurve(to: CGPoint(x: 0.51282*width, y: 0.7349*height), control1: CGPoint(x: 0.49724*width, y: 0.72783*height), control2: CGPoint(x: 0.5045*width, y: 0.73191*height))
        path.addCurve(to: CGPoint(x: 0.53993*width, y: 0.73938*height), control1: CGPoint(x: 0.52113*width, y: 0.73789*height), control2: CGPoint(x: 0.53016*width, y: 0.73938*height))
        path.closeSubpath()
        return path
    }
}


struct ClearNight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.32965*width, y: 0.07839*height))
        path.addLine(to: CGPoint(x: 0.31577*width, y: 0.11901*height))
        path.addLine(to: CGPoint(x: 0.27099*width, y: 0.11905*height))
        path.addLine(to: CGPoint(x: 0.30719*width, y: 0.1442*height))
        path.addLine(to: CGPoint(x: 0.2934*width, y: 0.18484*height))
        path.addLine(to: CGPoint(x: 0.32965*width, y: 0.15976*height))
        path.addLine(to: CGPoint(x: 0.36591*width, y: 0.18484*height))
        path.addLine(to: CGPoint(x: 0.35211*width, y: 0.1442*height))
        path.addLine(to: CGPoint(x: 0.38831*width, y: 0.11905*height))
        path.addLine(to: CGPoint(x: 0.34353*width, y: 0.11901*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.67442*width, y: 0.16745*height))
        path.addLine(to: CGPoint(x: 0.66054*width, y: 0.20806*height))
        path.addLine(to: CGPoint(x: 0.61576*width, y: 0.20811*height))
        path.addLine(to: CGPoint(x: 0.65196*width, y: 0.23325*height))
        path.addLine(to: CGPoint(x: 0.63817*width, y: 0.27389*height))
        path.addLine(to: CGPoint(x: 0.67442*width, y: 0.24882*height))
        path.addLine(to: CGPoint(x: 0.71068*width, y: 0.27389*height))
        path.addLine(to: CGPoint(x: 0.69688*width, y: 0.23325*height))
        path.addLine(to: CGPoint(x: 0.73308*width, y: 0.20811*height))
        path.addLine(to: CGPoint(x: 0.6883*width, y: 0.20806*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.30433*width, y: 0.73934*height))
        path.addLine(to: CGPoint(x: 0.29044*width, y: 0.77996*height))
        path.addLine(to: CGPoint(x: 0.24567*width, y: 0.78*height))
        path.addLine(to: CGPoint(x: 0.28187*width, y: 0.80515*height))
        path.addLine(to: CGPoint(x: 0.26807*width, y: 0.84579*height))
        path.addLine(to: CGPoint(x: 0.30433*width, y: 0.82071*height))
        path.addLine(to: CGPoint(x: 0.34058*width, y: 0.84579*height))
        path.addLine(to: CGPoint(x: 0.32678*width, y: 0.80515*height))
        path.addLine(to: CGPoint(x: 0.36298*width, y: 0.78*height))
        path.addLine(to: CGPoint(x: 0.31821*width, y: 0.77996*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.20629*width, y: 0.35209*height))
        path.addLine(to: CGPoint(x: 0.19241*width, y: 0.3927*height))
        path.addLine(to: CGPoint(x: 0.14763*width, y: 0.39275*height))
        path.addLine(to: CGPoint(x: 0.18383*width, y: 0.41789*height))
        path.addLine(to: CGPoint(x: 0.17003*width, y: 0.45853*height))
        path.addLine(to: CGPoint(x: 0.20629*width, y: 0.43346*height))
        path.addLine(to: CGPoint(x: 0.24254*width, y: 0.45853*height))
        path.addLine(to: CGPoint(x: 0.22875*width, y: 0.41789*height))
        path.addLine(to: CGPoint(x: 0.26495*width, y: 0.39275*height))
        path.addLine(to: CGPoint(x: 0.22017*width, y: 0.3927*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.73651*width, y: 0.62169*height))
        path.addLine(to: CGPoint(x: 0.72263*width, y: 0.66231*height))
        path.addLine(to: CGPoint(x: 0.67786*width, y: 0.66235*height))
        path.addLine(to: CGPoint(x: 0.71406*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.70026*width, y: 0.72814*height))
        path.addLine(to: CGPoint(x: 0.73651*width, y: 0.70307*height))
        path.addLine(to: CGPoint(x: 0.77277*width, y: 0.72814*height))
        path.addLine(to: CGPoint(x: 0.75897*width, y: 0.6875*height))
        path.addLine(to: CGPoint(x: 0.79517*width, y: 0.66235*height))
        path.addLine(to: CGPoint(x: 0.7504*width, y: 0.66231*height))
        path.closeSubpath()
        return path
    }
}


struct Lightning: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.48448*width, y: 0.38725*height))
        path.addLine(to: CGPoint(x: 0.67075*width, y: 0.31373*height))
        path.addLine(to: CGPoint(x: 0.36275*width, y: 0.84641*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.43791*height))
        path.addLine(to: CGPoint(x: 0.36275*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.4665*width, y: 0.10703*height))
        path.addLine(to: CGPoint(x: 0.60784*width, y: 0.10703*height))
        path.closeSubpath()
        return path
    }
}


struct Wind: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.76991*width, y: 0.50003*height))
        path.addCurve(to: CGPoint(x: 0.82825*width, y: 0.51385*height), control1: CGPoint(x: 0.79195*width, y: 0.50003*height), control2: CGPoint(x: 0.81139*width, y: 0.50464*height))
        path.addCurve(to: CGPoint(x: 0.86794*width, y: 0.55196*height), control1: CGPoint(x: 0.84511*width, y: 0.52306*height), control2: CGPoint(x: 0.85834*width, y: 0.53576*height))
        path.addCurve(to: CGPoint(x: 0.88235*width, y: 0.60783*height), control1: CGPoint(x: 0.87755*width, y: 0.56815*height), control2: CGPoint(x: 0.88235*width, y: 0.58678*height))
        path.addCurve(to: CGPoint(x: 0.86893*width, y: 0.66295*height), control1: CGPoint(x: 0.88235*width, y: 0.62848*height), control2: CGPoint(x: 0.87788*width, y: 0.64685*height))
        path.addCurve(to: CGPoint(x: 0.83305*width, y: 0.70091*height), control1: CGPoint(x: 0.85999*width, y: 0.67904*height), control2: CGPoint(x: 0.84803*width, y: 0.6917*height))
        path.addCurve(to: CGPoint(x: 0.78291*width, y: 0.71472*height), control1: CGPoint(x: 0.81808*width, y: 0.71012*height), control2: CGPoint(x: 0.80136*width, y: 0.71472*height))
        path.addCurve(to: CGPoint(x: 0.73686*width, y: 0.70303*height), control1: CGPoint(x: 0.76577*width, y: 0.71472*height), control2: CGPoint(x: 0.75042*width, y: 0.71083*height))
        path.addCurve(to: CGPoint(x: 0.70352*width, y: 0.6713*height), control1: CGPoint(x: 0.7233*width, y: 0.69524*height), control2: CGPoint(x: 0.71218*width, y: 0.68466*height))
        path.addCurve(to: CGPoint(x: 0.68713*width, y: 0.62605*height), control1: CGPoint(x: 0.69486*width, y: 0.65794*height), control2: CGPoint(x: 0.68939*width, y: 0.64286*height))
        path.addCurve(to: CGPoint(x: 0.6901*width, y: 0.60981*height), control1: CGPoint(x: 0.68619*width, y: 0.61978*height), control2: CGPoint(x: 0.68718*width, y: 0.61436*height))
        path.addCurve(to: CGPoint(x: 0.70211*width, y: 0.60206*height), control1: CGPoint(x: 0.69302*width, y: 0.60525*height), control2: CGPoint(x: 0.69702*width, y: 0.60267*height))
        path.addCurve(to: CGPoint(x: 0.71609*width, y: 0.60586*height), control1: CGPoint(x: 0.70738*width, y: 0.60125*height), control2: CGPoint(x: 0.71204*width, y: 0.60252*height))
        path.addCurve(to: CGPoint(x: 0.72414*width, y: 0.6218*height), control1: CGPoint(x: 0.72014*width, y: 0.6092*height), control2: CGPoint(x: 0.72282*width, y: 0.61451*height))
        path.addCurve(to: CGPoint(x: 0.73474*width, y: 0.64959*height), control1: CGPoint(x: 0.72565*width, y: 0.63233*height), control2: CGPoint(x: 0.72918*width, y: 0.64159*height))
        path.addCurve(to: CGPoint(x: 0.75564*width, y: 0.66841*height), control1: CGPoint(x: 0.74029*width, y: 0.65758*height), control2: CGPoint(x: 0.74726*width, y: 0.66386*height))
        path.addCurve(to: CGPoint(x: 0.78291*width, y: 0.67525*height), control1: CGPoint(x: 0.76403*width, y: 0.67297*height), control2: CGPoint(x: 0.77311*width, y: 0.67525*height))
        path.addCurve(to: CGPoint(x: 0.81441*width, y: 0.66659*height), control1: CGPoint(x: 0.7944*width, y: 0.67525*height), control2: CGPoint(x: 0.8049*width, y: 0.67236*height))
        path.addCurve(to: CGPoint(x: 0.83701*width, y: 0.64275*height), control1: CGPoint(x: 0.82392*width, y: 0.66082*height), control2: CGPoint(x: 0.83145*width, y: 0.65288*height))
        path.addCurve(to: CGPoint(x: 0.84534*width, y: 0.60783*height), control1: CGPoint(x: 0.84257*width, y: 0.63263*height), control2: CGPoint(x: 0.84534*width, y: 0.62099*height))
        path.addCurve(to: CGPoint(x: 0.82486*width, y: 0.55849*height), control1: CGPoint(x: 0.84534*width, y: 0.58759*height), control2: CGPoint(x: 0.83852*width, y: 0.57114*height))
        path.addCurve(to: CGPoint(x: 0.76991*width, y: 0.53951*height), control1: CGPoint(x: 0.81121*width, y: 0.54583*height), control2: CGPoint(x: 0.79289*width, y: 0.53951*height))
        path.addCurve(to: CGPoint(x: 0.7038*width, y: 0.54756*height), control1: CGPoint(x: 0.74844*width, y: 0.53951*height), control2: CGPoint(x: 0.7264*width, y: 0.54219*height))
        path.addCurve(to: CGPoint(x: 0.63388*width, y: 0.56593*height), control1: CGPoint(x: 0.6812*width, y: 0.55292*height), control2: CGPoint(x: 0.65789*width, y: 0.55904*height))
        path.addCurve(to: CGPoint(x: 0.55901*width, y: 0.5843*height), control1: CGPoint(x: 0.60986*width, y: 0.57281*height), control2: CGPoint(x: 0.58491*width, y: 0.57893*height))
        path.addCurve(to: CGPoint(x: 0.47779*width, y: 0.59235*height), control1: CGPoint(x: 0.53311*width, y: 0.58966*height), control2: CGPoint(x: 0.50604*width, y: 0.59235*height))
        path.addCurve(to: CGPoint(x: 0.39402*width, y: 0.58491*height), control1: CGPoint(x: 0.44859*width, y: 0.59235*height), control2: CGPoint(x: 0.42067*width, y: 0.58987*height))
        path.addCurve(to: CGPoint(x: 0.31675*width, y: 0.56319*height), control1: CGPoint(x: 0.36737*width, y: 0.57995*height), control2: CGPoint(x: 0.34161*width, y: 0.57271*height))
        path.addCurve(to: CGPoint(x: 0.30446*width, y: 0.55287*height), control1: CGPoint(x: 0.31091*width, y: 0.56117*height), control2: CGPoint(x: 0.30682*width, y: 0.55773*height))
        path.addCurve(to: CGPoint(x: 0.30319*width, y: 0.53769*height), control1: CGPoint(x: 0.30211*width, y: 0.54801*height), control2: CGPoint(x: 0.30168*width, y: 0.54295*height))
        path.addCurve(to: CGPoint(x: 0.31209*width, y: 0.52584*height), control1: CGPoint(x: 0.3047*width, y: 0.53242*height), control2: CGPoint(x: 0.30767*width, y: 0.52848*height))
        path.addCurve(to: CGPoint(x: 0.32805*width, y: 0.52554*height), control1: CGPoint(x: 0.31652*width, y: 0.52321*height), control2: CGPoint(x: 0.32184*width, y: 0.52311*height))
        path.addCurve(to: CGPoint(x: 0.39939*width, y: 0.54604*height), control1: CGPoint(x: 0.35122*width, y: 0.53485*height), control2: CGPoint(x: 0.375*width, y: 0.54168*height))
        path.addCurve(to: CGPoint(x: 0.47779*width, y: 0.55257*height), control1: CGPoint(x: 0.42378*width, y: 0.55039*height), control2: CGPoint(x: 0.44991*width, y: 0.55257*height))
        path.addCurve(to: CGPoint(x: 0.55774*width, y: 0.54467*height), control1: CGPoint(x: 0.50604*width, y: 0.55257*height), control2: CGPoint(x: 0.53269*width, y: 0.54993*height))
        path.addCurve(to: CGPoint(x: 0.63035*width, y: 0.5263*height), control1: CGPoint(x: 0.58279*width, y: 0.53941*height), control2: CGPoint(x: 0.60699*width, y: 0.53328*height))
        path.addCurve(to: CGPoint(x: 0.69985*width, y: 0.50793*height), control1: CGPoint(x: 0.6537*width, y: 0.51931*height), control2: CGPoint(x: 0.67687*width, y: 0.51319*height))
        path.addCurve(to: CGPoint(x: 0.76991*width, y: 0.50003*height), control1: CGPoint(x: 0.72282*width, y: 0.50266*height), control2: CGPoint(x: 0.74618*width, y: 0.50003*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.65751*width, y: 0.14706*height))
        path.addCurve(to: CGPoint(x: 0.69678*width, y: 0.15769*height), control1: CGPoint(x: 0.67201*width, y: 0.14706*height), control2: CGPoint(x: 0.6851*width, y: 0.1506*height))
        path.addCurve(to: CGPoint(x: 0.72446*width, y: 0.18729*height), control1: CGPoint(x: 0.70845*width, y: 0.16477*height), control2: CGPoint(x: 0.71768*width, y: 0.17464*height))
        path.addCurve(to: CGPoint(x: 0.73463*width, y: 0.23117*height), control1: CGPoint(x: 0.73124*width, y: 0.19995*height), control2: CGPoint(x: 0.73463*width, y: 0.21457*height))
        path.addCurve(to: CGPoint(x: 0.68491*width, y: 0.31392*height), control1: CGPoint(x: 0.73463*width, y: 0.26701*height), control2: CGPoint(x: 0.71806*width, y: 0.29459*height))
        path.addCurve(to: CGPoint(x: 0.54111*width, y: 0.34292*height), control1: CGPoint(x: 0.65176*width, y: 0.33326*height), control2: CGPoint(x: 0.60383*width, y: 0.34292*height))
        path.addCurve(to: CGPoint(x: 0.22698*width, y: 0.33707*height), control1: CGPoint(x: 0.51938*width, y: 0.34292*height), control2: CGPoint(x: 0.29746*width, y: 0.33934*height))
        path.addCurve(to: CGPoint(x: 0.20343*width, y: 0.32108*height), control1: CGPoint(x: 0.21177*width, y: 0.33658*height), control2: CGPoint(x: 0.20356*width, y: 0.32989*height))
        path.addCurve(to: CGPoint(x: 0.22386*width, y: 0.3031*height), control1: CGPoint(x: 0.20329*width, y: 0.31122*height), control2: CGPoint(x: 0.20816*width, y: 0.30335*height))
        path.addCurve(to: CGPoint(x: 0.54111*width, y: 0.30314*height), control1: CGPoint(x: 0.30041*width, y: 0.30191*height), control2: CGPoint(x: 0.52*width, y: 0.30314*height))
        path.addCurve(to: CGPoint(x: 0.65793*width, y: 0.28371*height), control1: CGPoint(x: 0.59234*width, y: 0.30314*height), control2: CGPoint(x: 0.63128*width, y: 0.29667*height))
        path.addCurve(to: CGPoint(x: 0.69791*width, y: 0.23117*height), control1: CGPoint(x: 0.68458*width, y: 0.27075*height), control2: CGPoint(x: 0.69791*width, y: 0.25324*height))
        path.addCurve(to: CGPoint(x: 0.68604*width, y: 0.19838*height), control1: CGPoint(x: 0.69791*width, y: 0.21721*height), control2: CGPoint(x: 0.69395*width, y: 0.20627*height))
        path.addCurve(to: CGPoint(x: 0.65751*width, y: 0.18654*height), control1: CGPoint(x: 0.67813*width, y: 0.19048*height), control2: CGPoint(x: 0.66862*width, y: 0.18654*height))
        path.addCurve(to: CGPoint(x: 0.63081*width, y: 0.19777*height), control1: CGPoint(x: 0.64639*width, y: 0.18654*height), control2: CGPoint(x: 0.63749*width, y: 0.19028*height))
        path.addCurve(to: CGPoint(x: 0.61767*width, y: 0.22814*height), control1: CGPoint(x: 0.62412*width, y: 0.20526*height), control2: CGPoint(x: 0.61974*width, y: 0.21538*height))
        path.addCurve(to: CGPoint(x: 0.61103*width, y: 0.24256*height), control1: CGPoint(x: 0.61692*width, y: 0.23381*height), control2: CGPoint(x: 0.6147*width, y: 0.23861*height))
        path.addCurve(to: CGPoint(x: 0.59648*width, y: 0.24757*height), control1: CGPoint(x: 0.60736*width, y: 0.24651*height), control2: CGPoint(x: 0.60251*width, y: 0.24818*height))
        path.addCurve(to: CGPoint(x: 0.58278*width, y: 0.23953*height), control1: CGPoint(x: 0.59008*width, y: 0.24717*height), control2: CGPoint(x: 0.58551*width, y: 0.24448*height))
        path.addCurve(to: CGPoint(x: 0.5801*width, y: 0.22298*height), control1: CGPoint(x: 0.58005*width, y: 0.23457*height), control2: CGPoint(x: 0.57915*width, y: 0.22905*height))
        path.addCurve(to: CGPoint(x: 0.60453*width, y: 0.16907*height), control1: CGPoint(x: 0.58273*width, y: 0.20172*height), control2: CGPoint(x: 0.59088*width, y: 0.18375*height))
        path.addCurve(to: CGPoint(x: 0.65751*width, y: 0.14706*height), control1: CGPoint(x: 0.61819*width, y: 0.1544*height), control2: CGPoint(x: 0.63585*width, y: 0.14706*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.19243*width, y: 0.66992*height))
        path.addCurve(to: CGPoint(x: 0.31533*width, y: 0.69088*height), control1: CGPoint(x: 0.23312*width, y: 0.68389*height), control2: CGPoint(x: 0.27408*width, y: 0.69088*height))
        path.addCurve(to: CGPoint(x: 0.36378*width, y: 0.6886*height), control1: CGPoint(x: 0.33266*width, y: 0.69088*height), control2: CGPoint(x: 0.34881*width, y: 0.69012*height))
        path.addCurve(to: CGPoint(x: 0.40813*width, y: 0.6842*height), control1: CGPoint(x: 0.37875*width, y: 0.68708*height), control2: CGPoint(x: 0.39354*width, y: 0.68561*height))
        path.addCurve(to: CGPoint(x: 0.45461*width, y: 0.68207*height), control1: CGPoint(x: 0.42273*width, y: 0.68278*height), control2: CGPoint(x: 0.43822*width, y: 0.68207*height))
        path.addCurve(to: CGPoint(x: 0.49854*width, y: 0.69331*height), control1: CGPoint(x: 0.47156*width, y: 0.68207*height), control2: CGPoint(x: 0.4862*width, y: 0.68582*height))
        path.addCurve(to: CGPoint(x: 0.52707*width, y: 0.72383*height), control1: CGPoint(x: 0.51088*width, y: 0.7008*height), control2: CGPoint(x: 0.52039*width, y: 0.71097*height))
        path.addCurve(to: CGPoint(x: 0.5371*width, y: 0.7674*height), control1: CGPoint(x: 0.53376*width, y: 0.73668*height), control2: CGPoint(x: 0.5371*width, y: 0.75121*height))
        path.addCurve(to: CGPoint(x: 0.52651*width, y: 0.81128*height), control1: CGPoint(x: 0.5371*width, y: 0.7838*height), control2: CGPoint(x: 0.53357*width, y: 0.79843*height))
        path.addCurve(to: CGPoint(x: 0.49798*width, y: 0.84134*height), control1: CGPoint(x: 0.51945*width, y: 0.82414*height), control2: CGPoint(x: 0.50994*width, y: 0.83416*height))
        path.addCurve(to: CGPoint(x: 0.45828*width, y: 0.85212*height), control1: CGPoint(x: 0.48602*width, y: 0.84853*height), control2: CGPoint(x: 0.47278*width, y: 0.85212*height))
        path.addCurve(to: CGPoint(x: 0.41449*width, y: 0.8377*height), control1: CGPoint(x: 0.44208*width, y: 0.85212*height), control2: CGPoint(x: 0.42749*width, y: 0.84732*height))
        path.addCurve(to: CGPoint(x: 0.38596*width, y: 0.80172*height), control1: CGPoint(x: 0.4015*width, y: 0.82808*height), control2: CGPoint(x: 0.39198*width, y: 0.81609*height))
        path.addCurve(to: CGPoint(x: 0.38412*width, y: 0.78638*height), control1: CGPoint(x: 0.3837*width, y: 0.79665*height), control2: CGPoint(x: 0.38308*width, y: 0.79154*height))
        path.addCurve(to: CGPoint(x: 0.3933*width, y: 0.77439*height), control1: CGPoint(x: 0.38516*width, y: 0.78122*height), control2: CGPoint(x: 0.38822*width, y: 0.77722*height))
        path.addCurve(to: CGPoint(x: 0.40715*width, y: 0.77332*height), control1: CGPoint(x: 0.39763*width, y: 0.77196*height), control2: CGPoint(x: 0.40225*width, y: 0.7716*height))
        path.addCurve(to: CGPoint(x: 0.41901*width, y: 0.78501*height), control1: CGPoint(x: 0.41204*width, y: 0.77504*height), control2: CGPoint(x: 0.416*width, y: 0.77894*height))
        path.addCurve(to: CGPoint(x: 0.43441*width, y: 0.8046*height), control1: CGPoint(x: 0.42221*width, y: 0.79271*height), control2: CGPoint(x: 0.42735*width, y: 0.79924*height))
        path.addCurve(to: CGPoint(x: 0.45828*width, y: 0.81265*height), control1: CGPoint(x: 0.44147*width, y: 0.80997*height), control2: CGPoint(x: 0.44943*width, y: 0.81265*height))
        path.addCurve(to: CGPoint(x: 0.48809*width, y: 0.80035*height), control1: CGPoint(x: 0.46996*width, y: 0.81265*height), control2: CGPoint(x: 0.47989*width, y: 0.80855*height))
        path.addCurve(to: CGPoint(x: 0.50038*width, y: 0.7674*height), control1: CGPoint(x: 0.49628*width, y: 0.79215*height), control2: CGPoint(x: 0.50038*width, y: 0.78117*height))
        path.addCurve(to: CGPoint(x: 0.4878*width, y: 0.73415*height), control1: CGPoint(x: 0.50038*width, y: 0.75364*height), control2: CGPoint(x: 0.49619*width, y: 0.74255*height))
        path.addCurve(to: CGPoint(x: 0.45461*width, y: 0.72155*height), control1: CGPoint(x: 0.47942*width, y: 0.72575*height), control2: CGPoint(x: 0.46836*width, y: 0.72155*height))
        path.addCurve(to: CGPoint(x: 0.40955*width, y: 0.72383*height), control1: CGPoint(x: 0.43898*width, y: 0.72155*height), control2: CGPoint(x: 0.42396*width, y: 0.72231*height))
        path.addCurve(to: CGPoint(x: 0.36505*width, y: 0.72838*height), control1: CGPoint(x: 0.39514*width, y: 0.72534*height), control2: CGPoint(x: 0.38031*width, y: 0.72686*height))
        path.addCurve(to: CGPoint(x: 0.31533*width, y: 0.73066*height), control1: CGPoint(x: 0.34979*width, y: 0.7299*height), control2: CGPoint(x: 0.33322*width, y: 0.73066*height))
        path.addCurve(to: CGPoint(x: 0.24653*width, y: 0.72443*height), control1: CGPoint(x: 0.29216*width, y: 0.73066*height), control2: CGPoint(x: 0.26923*width, y: 0.72858*height))
        path.addCurve(to: CGPoint(x: 0.18113*width, y: 0.70758*height), control1: CGPoint(x: 0.22384*width, y: 0.72028*height), control2: CGPoint(x: 0.20204*width, y: 0.71467*height))
        path.addCurve(to: CGPoint(x: 0.1687*width, y: 0.69756*height), control1: CGPoint(x: 0.1751*width, y: 0.70576*height), control2: CGPoint(x: 0.17096*width, y: 0.70242*height))
        path.addCurve(to: CGPoint(x: 0.16757*width, y: 0.68237*height), control1: CGPoint(x: 0.16644*width, y: 0.6927*height), control2: CGPoint(x: 0.16606*width, y: 0.68764*height))
        path.addCurve(to: CGPoint(x: 0.17633*width, y: 0.67068*height), control1: CGPoint(x: 0.16908*width, y: 0.67711*height), control2: CGPoint(x: 0.172*width, y: 0.67321*height))
        path.addCurve(to: CGPoint(x: 0.19243*width, y: 0.66992*height), control1: CGPoint(x: 0.18066*width, y: 0.66815*height), control2: CGPoint(x: 0.18603*width, y: 0.6679*height))
        path.closeSubpath()
        return path
    }
}


struct Sun: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.78595*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.9183*width, y: 0.5*height))
        path.move(to: CGPoint(x: 0.69935*width, y: 0.29902*height))
        path.addLine(to: CGPoint(x: 0.79657*width, y: 0.20261*height))
        path.move(to: CGPoint(x: 0.5*width, y: 0.21405*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.0817*height))
        path.move(to: CGPoint(x: 0.29984*width, y: 0.29739*height))
        path.addLine(to: CGPoint(x: 0.20507*width, y: 0.20261*height))
        path.move(to: CGPoint(x: 0.21487*width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.0817*width, y: 0.5*height))
        path.move(to: CGPoint(x: 0.2982*width, y: 0.70261*height))
        path.addLine(to: CGPoint(x: 0.20507*width, y: 0.79575*height))
        path.move(to: CGPoint(x: 0.5*width, y: 0.78431*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.9183*height))
        path.move(to: CGPoint(x: 0.70343*width, y: 0.70261*height))
        path.addLine(to: CGPoint(x: 0.79657*width, y: 0.79575*height))
        return path
    }
}



struct Rain: Shape {
    let mm : Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        
        path.move(to: CGPoint(x: 0.76747*width, y: 0.5956*height))
        path.addCurve(to: CGPoint(x: 0.75804*width, y: 0.63805*height), control1: CGPoint(x: 0.76747*width, y: 0.5956*height), control2: CGPoint(x: 0.76842*width, y: 0.60898*height))
        path.addCurve(to: CGPoint(x: 0.72467*width, y: 0.71895*height), control1: CGPoint(x: 0.74824*width, y: 0.66549*height), control2: CGPoint(x: 0.72319*width, y: 0.68952*height))
        path.addCurve(to: CGPoint(x: 0.77219*width, y: 0.76774*height), control1: CGPoint(x: 0.72608*width, y: 0.74691*height), control2: CGPoint(x: 0.74081*width, y: 0.76754*height))
        path.addCurve(to: CGPoint(x: 0.81699*width, y: 0.71822*height), control1: CGPoint(x: 0.80117*width, y: 0.76793*height), control2: CGPoint(x: 0.81693*width, y: 0.74026*height))
        path.addCurve(to: CGPoint(x: 0.78634*width, y: 0.6522*height), control1: CGPoint(x: 0.81707*width, y: 0.69318*height), control2: CGPoint(x: 0.7986*width, y: 0.67621*height))
        path.addCurve(to: CGPoint(x: 0.76747*width, y: 0.5956*height), control1: CGPoint(x: 0.76785*width, y: 0.61598*height), control2: CGPoint(x: 0.76756*width, y: 0.59455*height))
        path.closeSubpath()

        path.move(to: CGPoint(x: 0.39329*width, y: 0.55883*height))
        path.addCurve(to: CGPoint(x: 0.38386*width, y: 0.60128*height), control1: CGPoint(x: 0.39329*width, y: 0.55883*height), control2: CGPoint(x: 0.39423*width, y: 0.57222*height))
        path.addCurve(to: CGPoint(x: 0.35049*width, y: 0.68219*height), control1: CGPoint(x: 0.37406*width, y: 0.62873*height), control2: CGPoint(x: 0.34901*width, y: 0.65275*height))
        path.addCurve(to: CGPoint(x: 0.39801*width, y: 0.73098*height), control1: CGPoint(x: 0.3519*width, y: 0.71014*height), control2: CGPoint(x: 0.36662*width, y: 0.73078*height))
        path.addCurve(to: CGPoint(x: 0.44281*width, y: 0.68146*height), control1: CGPoint(x: 0.42699*width, y: 0.73117*height), control2: CGPoint(x: 0.44275*width, y: 0.7035*height))
        path.addCurve(to: CGPoint(x: 0.41215*width, y: 0.61543*height), control1: CGPoint(x: 0.44288*width, y: 0.65641*height), control2: CGPoint(x: 0.42442*width, y: 0.63945*height))
        path.addCurve(to: CGPoint(x: 0.39329*width, y: 0.55883*height), control1: CGPoint(x: 0.39367*width, y: 0.57922*height), control2: CGPoint(x: 0.39338*width, y: 0.55779*height))
        path.closeSubpath()

        
        if mm > 2 {
            path.move(to: CGPoint(x: 0.68986*width, y: 0.37174*height))
            path.addCurve(to: CGPoint(x: 0.68042*width, y: 0.41419*height), control1: CGPoint(x: 0.68986*width, y: 0.37174*height), control2: CGPoint(x: 0.6908*width, y: 0.38513*height))
            path.addCurve(to: CGPoint(x: 0.64706*width, y: 0.4951*height), control1: CGPoint(x: 0.67063*width, y: 0.44163*height), control2: CGPoint(x: 0.64558*width, y: 0.46566*height))
            path.addCurve(to: CGPoint(x: 0.69457*width, y: 0.54389*height), control1: CGPoint(x: 0.64847*width, y: 0.52305*height), control2: CGPoint(x: 0.66319*width, y: 0.54369*height))
            path.addCurve(to: CGPoint(x: 0.73938*width, y: 0.49437*height), control1: CGPoint(x: 0.72356*width, y: 0.54408*height), control2: CGPoint(x: 0.73932*width, y: 0.51641*height))
            path.addCurve(to: CGPoint(x: 0.70872*width, y: 0.42834*height), control1: CGPoint(x: 0.73945*width, y: 0.46932*height), control2: CGPoint(x: 0.72099*width, y: 0.45236*height))
            path.addCurve(to: CGPoint(x: 0.68986*width, y: 0.37174*height), control1: CGPoint(x: 0.69024*width, y: 0.39213*height), control2: CGPoint(x: 0.68995*width, y: 0.37069*height))
            path.closeSubpath()
        
        }
        
        if mm > 3 {
            
            path.move(to: CGPoint(x: 0.32875*width, y: 0.192*height))
            path.addCurve(to: CGPoint(x: 0.31931*width, y: 0.23445*height), control1: CGPoint(x: 0.32875*width, y: 0.192*height), control2: CGPoint(x: 0.32969*width, y: 0.20539*height))
            path.addCurve(to: CGPoint(x: 0.28595*width, y: 0.31536*height), control1: CGPoint(x: 0.30951*width, y: 0.2619*height), control2: CGPoint(x: 0.28446*width, y: 0.28592*height))
            path.addCurve(to: CGPoint(x: 0.33346*width, y: 0.36415*height), control1: CGPoint(x: 0.28736*width, y: 0.34331*height), control2: CGPoint(x: 0.30208*width, y: 0.36395*height))
            path.addCurve(to: CGPoint(x: 0.37827*width, y: 0.31463*height), control1: CGPoint(x: 0.36245*width, y: 0.36434*height), control2: CGPoint(x: 0.3782*width, y: 0.33667*height))
            path.addCurve(to: CGPoint(x: 0.34761*width, y: 0.2486*height), control1: CGPoint(x: 0.37834*width, y: 0.28958*height), control2: CGPoint(x: 0.35987*width, y: 0.27262*height))
            path.addCurve(to: CGPoint(x: 0.32875*width, y: 0.192*height), control1: CGPoint(x: 0.32912*width, y: 0.21239*height), control2: CGPoint(x: 0.32883*width, y: 0.19096*height))
            path.closeSubpath()
        }
        
        if mm > 4 {
            
            path.move(to: CGPoint(x: 0.61469*width, y: 0.10622*height))
            path.addCurve(to: CGPoint(x: 0.60526*width, y: 0.14867*height), control1: CGPoint(x: 0.61469*width, y: 0.10622*height), control2: CGPoint(x: 0.61564*width, y: 0.11961*height))
            path.addCurve(to: CGPoint(x: 0.5719*width, y: 0.22958*height), control1: CGPoint(x: 0.59546*width, y: 0.17611*height), control2: CGPoint(x: 0.57041*width, y: 0.20014*height))
            path.addCurve(to: CGPoint(x: 0.61941*width, y: 0.27837*height), control1: CGPoint(x: 0.5733*width, y: 0.25753*height), control2: CGPoint(x: 0.58803*width, y: 0.27816*height))
            path.addCurve(to: CGPoint(x: 0.66422*width, y: 0.22884*height), control1: CGPoint(x: 0.64839*width, y: 0.27855*height), control2: CGPoint(x: 0.66415*width, y: 0.25089*height))
            path.addCurve(to: CGPoint(x: 0.63356*width, y: 0.16282*height), control1: CGPoint(x: 0.66429*width, y: 0.2038*height), control2: CGPoint(x: 0.64582*width, y: 0.18683*height))
            path.addCurve(to: CGPoint(x: 0.61469*width, y: 0.10622*height), control1: CGPoint(x: 0.61507*width, y: 0.1266*height), control2: CGPoint(x: 0.61478*width, y: 0.10517*height))
            path.closeSubpath()
            
        }
        
        if mm > 6 {
            
            path.move(to: CGPoint(x: 0.16698*width, y: 0.45834*height))
            path.addCurve(to: CGPoint(x: 0.15755*width, y: 0.50079*height), control1: CGPoint(x: 0.16698*width, y: 0.45834*height), control2: CGPoint(x: 0.16793*width, y: 0.47173*height))
            path.addCurve(to: CGPoint(x: 0.12418*width, y: 0.5817*height), control1: CGPoint(x: 0.14775*width, y: 0.52824*height), control2: CGPoint(x: 0.1227*width, y: 0.55226*height))
            path.addCurve(to: CGPoint(x: 0.1717*width, y: 0.63049*height), control1: CGPoint(x: 0.12559*width, y: 0.60965*height), control2: CGPoint(x: 0.14032*width, y: 0.63029*height))
            path.addCurve(to: CGPoint(x: 0.2165*width, y: 0.58097*height), control1: CGPoint(x: 0.20068*width, y: 0.63068*height), control2: CGPoint(x: 0.21644*width, y: 0.60301*height))
            path.addCurve(to: CGPoint(x: 0.18585*width, y: 0.51494*height), control1: CGPoint(x: 0.21658*width, y: 0.55592*height), control2: CGPoint(x: 0.19811*width, y: 0.53896*height))
            path.addCurve(to: CGPoint(x: 0.16698*width, y: 0.45834*height), control1: CGPoint(x: 0.16736*width, y: 0.47873*height), control2: CGPoint(x: 0.16707*width, y: 0.45729*height))
            path.closeSubpath()
        }
        return path
    }
}
