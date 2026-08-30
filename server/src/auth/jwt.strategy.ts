import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Inject, Injectable, UnauthorizedException } from '@nestjs/common';
import type { ConfigType } from '@nestjs/config';
import { PrismaService } from 'src/prisma/prisma.service';
import { AuthConfig } from '../config/configuration';
import { t } from '../i18n/i18n.util';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    @Inject(AuthConfig.KEY)
    authConfig: ConfigType<typeof AuthConfig>,
    private prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: authConfig.jwtSecret,
    });
  }

  async validate(payload: { sub: string }) {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: {
        id: true,
        email: true,
        name: true,
        profileImage: true,
        isAdmin: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException(t('auth.userNotFound'));
    }

    // Reject pending users
    if (user.status === 'pending') {
      throw new UnauthorizedException(t('auth.accountPendingApproval'));
    }

    return user;
  }
}
