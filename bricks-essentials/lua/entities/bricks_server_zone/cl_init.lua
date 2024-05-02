include('shared.lua')

function ENT:Draw()

end

function ENT:Think()
	local min, max = self:GetCollisionBounds()
	debugoverlay.Box( self:GetPos(), min, max, 0.001, Color( 255, 255, 255, 25 ) )
end